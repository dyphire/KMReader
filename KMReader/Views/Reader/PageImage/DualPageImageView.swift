//
//  DualPageImageView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

// Dual page image view with synchronized zoom and pan
struct DualPageImageView: View {
  var viewModel: ReaderViewModel
  let firstPageIndex: Int
  let secondPageIndex: Int
  let screenSize: CGSize
  let isRTL: Bool

  @State private var scale: CGFloat = 1.0
  @State private var lastScale: CGFloat = 1.0
  @State private var offset: CGSize = .zero
  @State private var lastOffset: CGSize = .zero

  var imageWidth: CGFloat {
    screenSize.width / 2
  }

  var imageHeight: CGFloat {
    screenSize.height
  }

  var body: some View {
    HStack(spacing: 0) {
      if isRTL {
        PageImageView(viewModel: viewModel, pageIndex: secondPageIndex)
          .frame(width: imageWidth, height: imageHeight, alignment: .trailing)
          .clipped()

        PageImageView(viewModel: viewModel, pageIndex: firstPageIndex)
          .frame(width: imageWidth, height: imageHeight, alignment: .leading)
          .clipped()
      } else {
        PageImageView(viewModel: viewModel, pageIndex: firstPageIndex)
          .frame(width: imageWidth, height: imageHeight, alignment: .trailing)
          .clipped()

        PageImageView(viewModel: viewModel, pageIndex: secondPageIndex)
          .frame(width: imageWidth, height: imageHeight, alignment: .leading)
          .clipped()
      }
    }
    .frame(width: screenSize.width, height: screenSize.height)
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
    .task(id: firstPageIndex) {
      // Reset zoom state when switching pages
      scale = 1.0
      lastScale = 1.0
      offset = .zero
      lastOffset = .zero
    }
  }
}
