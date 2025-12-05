//
//  CollectionSeriesFilterView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct CollectionSeriesFilterView: View {
  @Binding var browseOpts: CollectionSeriesBrowseOptions
  @Binding var showFilterSheet: Bool

  var body: some View {
    HStack(spacing: 8) {
      LayoutModePicker()

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 6) {
          Image(systemName: "line.3.horizontal.decrease.circle")
            .padding(.leading, 4)

          if browseOpts.readStatusFilter != .all {
            Button {
              showFilterSheet = true
            } label: {
              FilterChip(
                label: "Read: \(browseOpts.readStatusFilter.displayName)",
                systemImage: "eye"
              )
            }
            .buttonStyle(.plain)
          }

          if browseOpts.seriesStatusFilter != .all {
            Button {
              showFilterSheet = true
            } label: {
              FilterChip(
                label: "Status: \(browseOpts.seriesStatusFilter.displayName)",
                systemImage: "chart.bar"
              )
            }
            .buttonStyle(.plain)
          }

          if browseOpts.readStatusFilter == .all && browseOpts.seriesStatusFilter == .all {
            Button {
              showFilterSheet = true
            } label: {
              FilterChip(
                label: "Filter",
                systemImage: "line.3.horizontal.decrease.circle"
              )
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.horizontal, 4)
      }

      Spacer()
    }
    .sheet(isPresented: $showFilterSheet) {
      CollectionSeriesBrowseOptionsSheet(browseOpts: $browseOpts)
    }
  }
}
