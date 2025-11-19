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

  @State private var hasSyncedInitialScroll = false
  @State private var showTapZoneOverlay = false
  @AppStorage("showTapZone") private var showTapZone: Bool = true

  var body: some View {
    GeometryReader { screenGeometry in
      let screenKey = "\(Int(screenGeometry.size.width))x\(Int(screenGeometry.size.height))"

      ZStack {
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
                  if hasSyncedInitialScroll && pageIndex != viewModel.currentPageIndex
                    && !isAtEndPage
                  {
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
          .id(screenKey)
          .onChange(of: screenKey) { _, _ in
            // Reset scroll sync flag when screen size changes
            hasSyncedInitialScroll = false
          }
        }

        // Tap zone overlay
        if showTapZoneOverlay {
          PageTapZoneOverlay(
            orientation: .vertical,
            isRTL: false
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
    }
  }

  private func triggerTapZoneDisplay() {
    guard showTapZone && !viewModel.pages.isEmpty else { return }
    showTapZoneOverlay = false
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      showTapZoneOverlay = true
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

  private func synchronizeInitialScrollIfNeeded(proxy: ScrollViewProxy) {
    guard !hasSyncedInitialScroll,
      viewModel.currentPageIndex >= 0,
      viewModel.currentPageIndex < viewModel.pages.count
    else {
      return
    }

    DispatchQueue.main.async {
      proxy.scrollTo(viewModel.currentPageIndex, anchor: .top)
      hasSyncedInitialScroll = true
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
