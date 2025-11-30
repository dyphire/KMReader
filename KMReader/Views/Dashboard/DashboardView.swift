//
//  DashboardView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Combine
import SwiftUI

struct DashboardView: View {
  @State private var bookViewModel = BookViewModel()
  @State private var seriesViewModel = SeriesViewModel()
  @State private var refreshTrigger = UUID()
  @State private var isRefreshDisabled = false

  @AppStorage("dashboard") private var dashboard: DashboardConfiguration =
    DashboardConfiguration()

  private func refreshDashboard() {
    refreshTrigger = UUID()
    isRefreshDisabled = true
    Task {
      try? await Task.sleep(nanoseconds: 2_000_000_000)  // 2 seconds
      isRefreshDisabled = false
    }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          ForEach(dashboard.sections, id: \.id) { section in
            switch section {
            case .keepReading, .onDeck, .recentlyReadBooks, .recentlyReleasedBooks,
              .recentlyAddedBooks:
              DashboardBooksSection(
                section: section,
                bookViewModel: bookViewModel,
                refreshTrigger: refreshTrigger,
                onBookUpdated: refreshDashboard
              )
              .transition(.move(edge: .top).combined(with: .opacity))

            case .recentlyUpdatedSeries, .recentlyAddedSeries:
              DashboardSeriesSection(
                section: section,
                seriesViewModel: seriesViewModel,
                refreshTrigger: refreshTrigger,
                onSeriesUpdated: refreshDashboard
              )
              .transition(.move(edge: .top).combined(with: .opacity))
            }
          }
        }
        .padding(.vertical)
      }
      .handleNavigation()
      .inlineNavigationBarTitle("Dashboard")
      .animation(.default, value: dashboard)
      #if !os(tvOS)
        .toolbar {
          ToolbarItem(placement: .automatic) {
            Button {
              refreshDashboard()
            } label: {
              Image(systemName: "arrow.clockwise.circle")
            }
            .disabled(isRefreshDisabled)
          }
        }
        .refreshable {
          refreshDashboard()
        }
      #endif
    }
  }

}
