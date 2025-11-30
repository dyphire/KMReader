//
//  DashboardSeriesSection.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct DashboardSeriesSection: View {
  let section: DashboardSection
  var seriesViewModel: SeriesViewModel
  let refreshTrigger: UUID
  var onSeriesUpdated: (() -> Void)? = nil

  @AppStorage("selectedLibraryId") private var selectedLibraryId: String = ""

  @State private var series: [Series] = []
  @State private var currentPage = 0
  @State private var hasMore = true
  @State private var isLoading = false
  @State private var lastTriggeredIndex: Int = -1
  @State private var hasLoadedInitial = false

  var body: some View {
    Group {
      // Don't show section if empty and initial load is complete
      if !series.isEmpty || isLoading || !hasLoadedInitial {
        VStack(alignment: .leading, spacing: 4) {
          Text(section.displayName)
            .font(.title3)
            .fontWeight(.bold)
            .padding(.horizontal)

          ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: 12) {
              ForEach(Array(series.enumerated()), id: \.element.id) { index, s in
                NavigationLink(value: NavDestination.seriesDetail(seriesId: s.id)) {
                  SeriesCardView(
                    series: s,
                    cardWidth: PlatformHelper.dashboardCardWidth,
                    onActionCompleted: onSeriesUpdated
                  )
                }
                .focusPadding()
                .buttonStyle(.plain)
                .onAppear {
                  // Trigger load when we're near the last item (within last 3 items)
                  // Only trigger once per index to avoid repeated loads
                  if index >= series.count - 3 && hasMore && !isLoading
                    && lastTriggeredIndex != index
                  {
                    lastTriggeredIndex = index
                    Task {
                      await loadMore()
                    }
                  }
                }
              }

              // Loading indicator at the end
              if isLoading {
                ProgressView()
                  .frame(width: PlatformHelper.dashboardCardWidth, height: 200)
                  .padding(.trailing, 12)
              }
            }
            .padding()
          }
          #if os(tvOS)
            .focusSection()
          #endif
        }
        .padding(.bottom, 16)
      }
    }
    .onChange(of: selectedLibraryId) {
      Task {
        await loadInitial()
      }
    }
    .onChange(of: refreshTrigger) {
      Task {
        await loadInitial()
      }
    }
    .onAppear {
      // Load data when view appears (if not already loaded or if empty due to cancelled request)
      if !hasLoadedInitial || (series.isEmpty && !isLoading) {
        Task {
          await loadInitial()
        }
      }
    }
  }

  private func loadInitial() async {
    currentPage = 0
    hasMore = true
    lastTriggeredIndex = -1
    hasLoadedInitial = false

    // Load first page first, then replace
    await loadMore(reset: true)
    hasLoadedInitial = true
  }

  private func loadMore(reset: Bool = false) async {
    guard hasMore, !isLoading else { return }
    isLoading = true

    do {
      let page: Page<Series>

      switch section {
      case .recentlyAddedSeries:
        page = try await SeriesService.shared.getNewSeries(
          libraryId: selectedLibraryId,
          page: currentPage,
          size: 20
        )

      case .recentlyUpdatedSeries:
        page = try await SeriesService.shared.getUpdatedSeries(
          libraryId: selectedLibraryId,
          page: currentPage,
          size: 20
        )

      default:
        isLoading = false
        return
      }

      withAnimation {
        if reset {
          series = page.content
        } else {
          series.append(contentsOf: page.content)
        }
      }

      hasMore = !page.last
      currentPage += 1

      // Reset trigger index after loading to allow next trigger
      lastTriggeredIndex = -1
    } catch {
      ErrorManager.shared.alert(error: error)
    }

    isLoading = false
  }
}
