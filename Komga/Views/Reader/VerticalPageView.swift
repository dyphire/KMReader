//
//  VerticalPageView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct VerticalPageView: View {
  @Bindable var viewModel: ReaderViewModel
  @Binding var isAtEndPage: Bool
  @Binding var showingControls: Bool
  let nextBook: Book?
  let onDismiss: () -> Void
  let onNextBook: (String) -> Void
  let goToNextPage: () -> Void
  let goToPreviousPage: () -> Void
  let toggleControls: () -> Void

  var body: some View {
    GeometryReader { screenGeometry in
      ScrollViewReader { proxy in
        ScrollView(.vertical) {
          LazyVStack(spacing: 0) {
            ForEach(0..<viewModel.pages.count, id: \.self) { pageIndex in
              GeometryReader { geometry in
                ZStack {
                  PageImageView(
                    viewModel: viewModel,
                    pageIndex: pageIndex
                  )
                }
                .contentShape(Rectangle())
                .simultaneousGesture(verticalTapGesture(height: geometry.size.height))
              }
              .frame(width: screenGeometry.size.width, height: screenGeometry.size.height)
              .id(pageIndex)
              .onAppear {
                // Update current page when page appears
                if pageIndex != viewModel.currentPageIndex && !isAtEndPage {
                  viewModel.currentPageIndex = pageIndex
                }
              }
            }

            // End page after last page
            endPageView
              .frame(width: screenGeometry.size.width, height: screenGeometry.size.height)
              .id("endPage")
              .onAppear {
                isAtEndPage = true
                showingControls = true  // Show controls when end page appears
              }
          }
        }
        .scrollTargetBehavior(.paging)
        .onChange(of: viewModel.currentPageIndex) { _, newPage in
          // Scroll to current page when changed externally (e.g., from slider)
          if !isAtEndPage {
            withAnimation {
              proxy.scrollTo(newPage, anchor: .top)
            }
          }
        }
        .onChange(of: isAtEndPage) { _, isEnd in
          if isEnd {
            withAnimation {
              proxy.scrollTo("endPage", anchor: .top)
            }
          }
        }
      }
    }
  }

  private func verticalTapGesture(height: CGFloat) -> some Gesture {
    SpatialTapGesture()
      .onEnded { value in
        guard height > 0 else { return }
        let normalizedY = max(0, min(1, value.location.y / height))
        if normalizedY < 0.35 {
          goToPreviousPage()
        } else if normalizedY > 0.65 {
          goToNextPage()
        } else {
          toggleControls()
        }
      }
  }

  // End page view with buttons and info
  private var endPageView: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      EndPageView(
        nextBook: nextBook,
        onDismiss: onDismiss,
        onNextBook: onNextBook
      )
    }
  }
}
