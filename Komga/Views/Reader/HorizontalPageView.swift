//
//  HorizontalPageView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct HorizontalPageView: View {
  @Bindable var viewModel: ReaderViewModel
  @Binding var isAtEndPage: Bool
  @Binding var showingControls: Bool
  let nextBook: Book?
  let onDismiss: () -> Void
  let onNextBook: (String) -> Void
  let goToNextPage: () -> Void
  let goToPreviousPage: () -> Void
  let toggleControls: () -> Void

  private var tabViewSelection: Binding<Int> {
    Binding(
      get: getSelectedDisplayIndex,
      set: setSelectedDisplayIndex
    )
  }

  var body: some View {
    TabView(selection: tabViewSelection) {
      // For RTL, show end page first
      if viewModel.readingDirection == .rtl {
        endPageView
          .tag(-1)
      }

      ForEach(0..<viewModel.pages.count, id: \.self) { displayIndex in
        GeometryReader { geometry in
          ZStack {
            PageImageView(
              viewModel: viewModel,
              pageIndex: viewModel.displayIndexToPageIndex(displayIndex)
            )
          }
          .contentShape(Rectangle())
          .simultaneousGesture(horizontalTapGesture(width: geometry.size.width))
        }
        .tag(displayIndex)
        .onAppear {
          // When a page appears in TabView, preload adjacent pages immediately
          // This ensures images are ready before user swipes to them
          Task(priority: .userInitiated) {
            await viewModel.preloadPages()
          }
        }
      }

      // For LTR, show end page last
      if viewModel.readingDirection == .ltr {
        endPageView
          .tag(viewModel.pages.count)
      }
    }
    .tabViewStyle(.page(indexDisplayMode: .never))
    .indexViewStyle(.page(backgroundDisplayMode: .never))
  }

  // Get the current selected display index
  private func getSelectedDisplayIndex() -> Int {
    if isAtEndPage {
      // For LTR, end page is at pages.count; for RTL, end page is at -1
      return viewModel.readingDirection == .rtl ? -1 : viewModel.pages.count
    }
    return viewModel.pageIndexToDisplayIndex(viewModel.currentPageIndex)
  }

  // Handle display index change
  private func setSelectedDisplayIndex(_ displayIndex: Int) {
    // Remove withAnimation to avoid conflict with TabView's built-in animation
    // Check if it's the end page
    let endPageIndex = viewModel.readingDirection == .rtl ? -1 : viewModel.pages.count
    if displayIndex == endPageIndex {
      isAtEndPage = true
      showingControls = true  // Show controls when reaching end page
    } else {
      isAtEndPage = false
      let newPageIndex = viewModel.displayIndexToPageIndex(displayIndex)
      if newPageIndex != viewModel.currentPageIndex {
        viewModel.currentPageIndex = newPageIndex
        // Immediately trigger aggressive preload for next pages
        // This ensures images are ready before user swipes to them
        Task(priority: .userInitiated) {
          await viewModel.preloadPages()
        }
      }
    }
  }

  private func horizontalTapGesture(width: CGFloat) -> some Gesture {
    SpatialTapGesture()
      .onEnded { value in
        guard width > 0 else { return }
        let normalizedX = max(0, min(1, value.location.x / width))
        if normalizedX < 0.35 {
          goToPreviousPage()
        } else if normalizedX > 0.65 {
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
