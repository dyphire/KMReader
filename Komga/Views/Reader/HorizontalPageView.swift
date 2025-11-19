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

  @State private var hasSyncedInitialScroll = false
  @State private var showTapZoneOverlay = false
  @AppStorage("showTapZone") private var showTapZone: Bool = true

  var body: some View {
    GeometryReader { screenGeometry in
      let screenKey = "\(Int(screenGeometry.size.width))x\(Int(screenGeometry.size.height))"

      ZStack {
        ScrollViewReader { proxy in
          ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
              // For RTL, show end page first
              if viewModel.readingDirection == .rtl {
                endPageView(width: screenGeometry.size.width, height: screenGeometry.size.height)
                  .id("endPage")
                  .onAppear {
                    isAtEndPage = true
                    showingControls = true  // Show controls when end page appears
                  }
              }

              ForEach(0..<viewModel.pages.count, id: \.self) { displayIndex in
                pageView(
                  displayIndex: displayIndex,
                  width: screenGeometry.size.width,
                  height: screenGeometry.size.height
                )
                .id(displayIndex)
                .onAppear {
                  // Update current page when page appears
                  let pageIndex = viewModel.displayIndexToPageIndex(displayIndex)
                  if hasSyncedInitialScroll && pageIndex != viewModel.currentPageIndex
                    && !isAtEndPage
                  {
                    viewModel.currentPageIndex = pageIndex
                    // Preload adjacent pages immediately
                    Task(priority: .userInitiated) {
                      await viewModel.preloadPages()
                    }
                  }
                }
              }

              // For LTR, show end page last
              if viewModel.readingDirection == .ltr {
                endPageView(width: screenGeometry.size.width, height: screenGeometry.size.height)
                  .id("endPage")
                  .onAppear {
                    isAtEndPage = true
                    showingControls = true  // Show controls when end page appears
                  }
              }
            }
            .scrollTargetLayout()
          }
          .scrollTargetBehavior(.paging)
          .scrollIndicators(.hidden)
          .onAppear {
            synchronizeInitialScrollIfNeeded(proxy: proxy)
          }
          .onChange(of: viewModel.pages.count) { _, _ in
            hasSyncedInitialScroll = false
            synchronizeInitialScrollIfNeeded(proxy: proxy)
          }
          .onChange(of: viewModel.currentPageIndex) { _, newPage in
            // Scroll to current page when changed externally (e.g., from slider)
            if !isAtEndPage {
              let displayIndex = viewModel.pageIndexToDisplayIndex(newPage)
              withAnimation {
                proxy.scrollTo(displayIndex, anchor: .leading)
              }
            }
          }
          .onChange(of: isAtEndPage) { _, isEnd in
            if isEnd {
              withAnimation {
                proxy.scrollTo("endPage", anchor: .leading)
              }
            }
          }
          .id(screenKey)
          .onChange(of: screenKey) { _, _ in
            // Reset scroll sync flag when screen size changes
            hasSyncedInitialScroll = false
          }
        }

        // Tap zone overlay
        if showTapZoneOverlay {
          PageTapZoneOverlay(
            orientation: .horizontal,
            isRTL: viewModel.readingDirection == .rtl
          )
        }
      }
      .onAppear {
        // Show tap zone overlay when view appears with pages loaded
        if showTapZone && !viewModel.pages.isEmpty && !showTapZoneOverlay {
          showTapZoneOverlay = true
        }
      }
      .onChange(of: viewModel.pages.count) { oldCount, newCount in
        // Show tap zone overlay when pages are first loaded
        if oldCount == 0 && newCount > 0 {
          triggerTapZoneDisplay()
        }
      }
      .onChange(of: screenKey) {
        // Show tap zone overlay when screen orientation changes
        triggerTapZoneDisplay()
      }
      .onChange(of: viewModel.readingDirection) {
        // Show tap zone overlay when reading direction changes
        triggerTapZoneDisplay()
      }
    }
  }

  private func triggerTapZoneDisplay() {
    guard showTapZone && !viewModel.pages.isEmpty else { return }
    showTapZoneOverlay = false
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      showTapZoneOverlay = true
    }
  }

  private func pageView(displayIndex: Int, width: CGFloat, height: CGFloat) -> some View {
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
    .frame(width: width, height: height)
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

  private func synchronizeInitialScrollIfNeeded(proxy: ScrollViewProxy) {
    guard !hasSyncedInitialScroll,
      viewModel.currentPageIndex >= 0,
      viewModel.currentPageIndex < viewModel.pages.count
    else {
      return
    }

    DispatchQueue.main.async {
      let displayIndex = viewModel.pageIndexToDisplayIndex(viewModel.currentPageIndex)
      proxy.scrollTo(displayIndex, anchor: .leading)
      hasSyncedInitialScroll = true
    }
  }

  // End page view with buttons and info
  private func endPageView(width: CGFloat, height: CGFloat) -> some View {
    ZStack {
      Color.black.ignoresSafeArea()
      EndPageView(
        nextBook: nextBook,
        onDismiss: onDismiss,
        onNextBook: onNextBook
      )
    }
    .frame(width: width, height: height)
  }
}
