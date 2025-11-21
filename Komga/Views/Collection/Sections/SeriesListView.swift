//
//  SeriesListView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

// Series list view for collection
struct SeriesListView: View {
  let collectionId: String
  @Bindable var seriesViewModel: SeriesViewModel

  @AppStorage("collectionSeriesBrowseOptions") private var browseOpts: SeriesBrowseOptions =
    SeriesBrowseOptions()

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("Series")
          .font(.headline)

        Spacer()

        SeriesFilterView(browseOpts: $browseOpts)
      }

      if seriesViewModel.isLoading && seriesViewModel.series.isEmpty {
        ProgressView()
          .frame(maxWidth: .infinity)
          .padding()
      } else {
        LazyVStack(spacing: 8) {
          ForEach(seriesViewModel.series) { series in
            NavigationLink(value: NavDestination.seriesDetail(seriesId: series.id)) {
              SeriesRowView(
                series: series,
                onActionCompleted: {
                  Task {
                    await seriesViewModel.loadCollectionSeries(
                      collectionId: collectionId, browseOpts: browseOpts, refresh: true)
                  }
                }
              )
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
              Button(role: .destructive) {
                Task {
                  do {
                    try await CollectionService.shared.removeSeriesFromCollection(
                      collectionId: collectionId, seriesId: series.id)
                    await seriesViewModel.loadCollectionSeries(
                      collectionId: collectionId, browseOpts: browseOpts, refresh: true)
                  } catch {
                  }
                }
              } label: {
                Label("Remove", systemImage: "trash")
              }
            }
            .onAppear {
              if series.id == seriesViewModel.series.last?.id {
                Task {
                  await seriesViewModel.loadCollectionSeries(
                    collectionId: collectionId, browseOpts: browseOpts, refresh: false)
                }
              }
            }
          }

          if seriesViewModel.isLoading && !seriesViewModel.series.isEmpty {
            ProgressView()
              .frame(maxWidth: .infinity)
              .padding()
          }
        }
      }
    }
    .task(id: collectionId) {
      await seriesViewModel.loadCollectionSeries(
        collectionId: collectionId, browseOpts: browseOpts, refresh: true)
    }
    .onChange(of: browseOpts) {
      Task {
        await seriesViewModel.loadCollectionSeries(
          collectionId: collectionId, browseOpts: browseOpts, refresh: true)
      }
    }
  }
}
