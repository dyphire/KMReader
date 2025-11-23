//
//  SinglePageImageView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

// Single page image view with zoom and pan support
struct SinglePageImageView: View {
  var viewModel: ReaderViewModel
  let pageIndex: Int

  @State private var scale: CGFloat = 1.0
  @State private var lastScale: CGFloat = 1.0
  @State private var offset: CGSize = .zero
  @State private var lastOffset: CGSize = .zero

  var body: some View {
    PageImageView(viewModel: viewModel, pageIndex: pageIndex)
      .scaleEffect(scale, anchor: .center)
      .offset(offset)
      .gesture(
        MagnificationGesture()
          .onChanged { value in
            let delta = value / lastScale
            lastScale = value
            scale *= delta
          }
          .onEnded { _ in
            lastScale = 1.0
            if scale < 1.0 {
              withAnimation {
                scale = 1.0
                offset = .zero
                lastOffset = .zero
              }
            } else if scale > 4.0 {
              withAnimation {
                scale = 4.0
              }
            }
          }
      )
      .onTapGesture(count: 2) {
        // Double tap to zoom in/out
        if scale > 1.0 {
          withAnimation {
            scale = 1.0
            offset = .zero
            lastOffset = .zero
          }
        } else {
          withAnimation {
            scale = 2.0
          }
        }
      }
      .simultaneousGesture(
        DragGesture(
          minimumDistance: scale > 1.0 ? 0 : CGFloat.greatestFiniteMagnitude
        )
        .onChanged { value in
          guard scale > 1.0 else { return }
          offset = CGSize(
            width: lastOffset.width + value.translation.width,
            height: lastOffset.height + value.translation.height
          )
        }
        .onEnded { _ in
          if scale > 1.0 {
            lastOffset = offset
          } else {
            lastOffset = .zero
            offset = .zero
          }
        }
      )
      .task(id: pageIndex) {
        // Reset zoom state when switching pages
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
      }
  }
}
