//
//  SeriesBrowseView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct SeriesBrowseView: View {
  let layoutHelper: BrowseLayoutHelper
  let searchText: String
  let spacing: CGFloat = 12

  @AppStorage("seriesBrowseOptions") private var browseOpts: SeriesBrowseOptions =
    SeriesBrowseOptions()
  @AppStorage("dashboard") private var dashboard: DashboardConfiguration = DashboardConfiguration()
  @AppStorage("browseLayout") private var browseLayout: BrowseLayoutMode = .grid

  @State private var viewModel = SeriesViewModel()

  var body: some View {
    VStack(spacing: 0) {
      SeriesFilterView(browseOpts: $browseOpts)
        .padding(spacing)

      BrowseStateView(
        isLoading: viewModel.isLoading,
        isEmpty: viewModel.series.isEmpty,
        emptyIcon: "books.vertical",
        emptyTitle: "No series found",
        emptyMessage: "Try selecting a different library.",
        onRetry: {
          Task {
            await viewModel.loadSeries(
              browseOpts: browseOpts, searchText: searchText, libraryIds: dashboard.libraryIds,
              refresh: true)
          }
        }
      ) {
        switch browseLayout {
        case .grid:
          LazyVGrid(columns: layoutHelper.columns, spacing: spacing) {
            ForEach(Array(viewModel.series.enumerated()), id: \.element.id) { index, series in
              NavigationLink(value: NavDestination.seriesDetail(seriesId: series.id)) {
                SeriesCardView(
                  series: series,
                  cardWidth: layoutHelper.cardWidth,
                  onActionCompleted: {
                    Task {
                      await viewModel.loadSeries(
                        browseOpts: browseOpts, searchText: searchText,
                        libraryIds: dashboard.libraryIds, refresh: true)
                    }
                  }
                )
              }
              .focusPadding()
              .buttonStyle(.plain)
              .onAppear {
                if index >= viewModel.series.count - 3 {
                  Task {
                    await viewModel.loadSeries(
                      browseOpts: browseOpts, searchText: searchText,
                      libraryIds: dashboard.libraryIds, refresh: false)
                  }
                }
              }
            }
          }
        case .list:
          LazyVStack(spacing: spacing) {
            ForEach(Array(viewModel.series.enumerated()), id: \.element.id) { index, series in
              NavigationLink(value: NavDestination.seriesDetail(seriesId: series.id)) {
                SeriesRowView(
                  series: series,
                  onActionCompleted: {
                    Task {
                      await viewModel.loadSeries(
                        browseOpts: browseOpts, searchText: searchText,
                        libraryIds: dashboard.libraryIds, refresh: true)
                    }
                  }
                )
              }
              .buttonStyle(.plain)
              .onAppear {
                if index >= viewModel.series.count - 3 {
                  Task {
                    await viewModel.loadSeries(
                      browseOpts: browseOpts, searchText: searchText,
                      libraryIds: dashboard.libraryIds, refresh: false)
                  }
                }
              }
            }
          }
        }
      }
    }
    .task {
      if viewModel.series.isEmpty {
        await viewModel.loadSeries(
          browseOpts: browseOpts, searchText: searchText, libraryIds: dashboard.libraryIds,
          refresh: true)
      }
    }
    .onChange(of: browseOpts) { _, newValue in
      Task {
        await viewModel.loadSeries(
          browseOpts: newValue, searchText: searchText, libraryIds: dashboard.libraryIds,
          refresh: true)
      }
    }
    .onChange(of: searchText) { _, newValue in
      Task {
        await viewModel.loadSeries(
          browseOpts: browseOpts, searchText: newValue, libraryIds: dashboard.libraryIds,
          refresh: true)
      }
    }
    .onChange(of: dashboard.libraryIds) { _, _ in
      Task {
        await viewModel.loadSeries(
          browseOpts: browseOpts, searchText: searchText, libraryIds: dashboard.libraryIds,
          refresh: true)
      }
    }
  }
}
