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
  @State private var pendingRefreshTask: Task<Void, Never>?
  @State private var showLibraryPicker = false
  @State private var shouldRefreshAfterReading = false

  @AppStorage("dashboard") private var dashboard: DashboardConfiguration = DashboardConfiguration()
  @AppStorage("currentInstanceId") private var currentInstanceId: String = ""
  @AppStorage("enableSSEAutoRefresh") private var enableSSEAutoRefresh: Bool = true
  @AppStorage("enableSSE") private var enableSSE: Bool = true
  @AppStorage("serverLastUpdate") private var serverLastUpdateInterval: TimeInterval = 0

  @Environment(ReaderPresentationManager.self) private var readerPresentation

  private let sseService = SSEService.shared
  private let debounceInterval: TimeInterval = 5.0  // 5 seconds debounce - wait for events to settle

  private var lastServerEventText: Text {
    guard serverLastUpdateInterval > 0 else { return Text("Server not updated yet") }
    let lastEventTime = Date(timeIntervalSince1970: serverLastUpdateInterval)
    return Text("Server updated \(lastEventTime, style: .relative) ago")
  }

  private func performRefresh() {
    // Update refresh trigger to cause all sections to reload
    refreshTrigger = UUID()
    isRefreshDisabled = true
    Task {
      try? await Task.sleep(nanoseconds: 2_000_000_000)  // 2 seconds
      isRefreshDisabled = false
    }
  }

  private func refreshDashboard() {
    // Cancel any pending debounced refresh
    pendingRefreshTask?.cancel()
    pendingRefreshTask = nil
    shouldRefreshAfterReading = false

    // Update last event time for manual refreshes
    serverLastUpdateInterval = Date().timeIntervalSince1970

    // Check SSE connection status and reconnect if disconnected
    if enableSSE && !sseService.connected {
      sseService.connect()
    }

    // Perform refresh immediately
    performRefresh()
  }

  private func scheduleRefresh() {
    // Skip if auto-refresh is disabled
    guard enableSSEAutoRefresh else { return }

    // Cancel any existing pending refresh
    pendingRefreshTask?.cancel()
    pendingRefreshTask = nil

    // Defer refresh while actively reading
    if isReaderActive {
      shouldRefreshAfterReading = true
      return
    }

    // Schedule a new refresh after debounce interval
    // This ensures the last event will always trigger a refresh
    pendingRefreshTask = Task {
      try? await Task.sleep(nanoseconds: UInt64(debounceInterval * 1_000_000_000))

      // Check if task was cancelled
      guard !Task.isCancelled else { return }

      // Perform the refresh
      await MainActor.run {
        // If reader became active while waiting, defer refresh until it closes
        if isReaderActive {
          shouldRefreshAfterReading = true
        } else {
          // Debounce expired - refresh to ensure last event always triggers
          performRefresh()
        }
        pendingRefreshTask = nil
      }
    }
  }

  private func shouldRefreshForLibrary(_ libraryId: String) -> Bool {
    // If dashboard shows all libraries (empty array), refresh for any library
    // Otherwise, only refresh if the library matches
    return dashboard.libraryIds.isEmpty || dashboard.libraryIds.contains(libraryId)
  }

  private var isReaderActive: Bool {
    readerPresentation.readerState != nil
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          HStack {
            if enableSSE {
              #if os(tvOS)
                Button {
                  refreshDashboard()
                } label: {
                  Label("Refresh", systemImage: "arrow.clockwise.circle")
                }
                .disabled(isRefreshDisabled)
              #endif
              HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                  .foregroundColor(.secondary)
                lastServerEventText
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
            }
            Spacer()
          }.padding()

          ForEach(dashboard.sections, id: \.id) { section in
            switch section {
            case .keepReading, .onDeck, .recentlyReadBooks, .recentlyReleasedBooks,
              .recentlyAddedBooks:
              DashboardBooksSection(
                section: section,
                bookViewModel: bookViewModel,
                refreshTrigger: refreshTrigger,
                onBookUpdated: refreshDashboard,
              )
              .transition(.move(edge: .top).combined(with: .opacity))

            case .recentlyUpdatedSeries, .recentlyAddedSeries:
              DashboardSeriesSection(
                section: section,
                seriesViewModel: seriesViewModel,
                refreshTrigger: refreshTrigger,
                onSeriesUpdated: refreshDashboard,
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
      .onChange(of: currentInstanceId) { _, _ in
        // Reset server last update time when switching servers
        serverLastUpdateInterval = 0
        // Bypass auto-refresh setting for configuration changes
        refreshDashboard()
      }
      .onChange(of: dashboard.libraryIds) { _, _ in
        // Bypass auto-refresh setting for configuration changes
        refreshDashboard()
      }
      .onAppear {
        setupSSEHandlers()
      }
      .onDisappear {
        cleanupSSEHandlers()
        // Cancel any pending refresh when view disappears
        pendingRefreshTask?.cancel()
        pendingRefreshTask = nil
      }
      .onChange(of: enableSSEAutoRefresh) { _, newValue in
        // Cancel any pending refresh when auto-refresh is disabled
        if !newValue {
          pendingRefreshTask?.cancel()
          pendingRefreshTask = nil
        }
      }
      .onChange(of: readerPresentation.readerState) { _, newState in
        if newState != nil {
          // Reader opened - cancel any pending dashboard refresh
          pendingRefreshTask?.cancel()
          pendingRefreshTask = nil
        } else if shouldRefreshAfterReading {
          shouldRefreshAfterReading = false
          refreshDashboard()
        }
      }
      #if !os(tvOS)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button {
              showLibraryPicker = true
            } label: {
              Image(systemName: "books.vertical")
            }
          }
          ToolbarItem(placement: .confirmationAction) {
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
        .sheet(isPresented: $showLibraryPicker) {
          LibraryPickerSheet()
        }
      #endif
    }
  }

  private func setupSSEHandlers() {
    // Series events
    sseService.onSeriesAdded = { event in
      if shouldRefreshForLibrary(event.libraryId) {
        scheduleRefresh()
      }
    }
    sseService.onSeriesChanged = { event in
      if shouldRefreshForLibrary(event.libraryId) {
        scheduleRefresh()
      }
    }
    sseService.onSeriesDeleted = { event in
      if shouldRefreshForLibrary(event.libraryId) {
        scheduleRefresh()
      }
    }

    // Book events
    sseService.onBookAdded = { event in
      if shouldRefreshForLibrary(event.libraryId) {
        scheduleRefresh()
      }
    }
    sseService.onBookChanged = { event in
      if shouldRefreshForLibrary(event.libraryId) {
        scheduleRefresh()
      }
    }
    sseService.onBookDeleted = { event in
      if shouldRefreshForLibrary(event.libraryId) {
        scheduleRefresh()
      }
    }

    // Read progress events - always refresh as they affect multiple sections
    sseService.onReadProgressChanged = { _ in
      scheduleRefresh()
    }
    sseService.onReadProgressDeleted = { _ in
      scheduleRefresh()
    }
    sseService.onReadProgressSeriesChanged = { _ in
      scheduleRefresh()
    }
    sseService.onReadProgressSeriesDeleted = { _ in
      scheduleRefresh()
    }
  }

  private func cleanupSSEHandlers() {
    // Clear handlers to avoid memory leaks
    sseService.onSeriesAdded = nil
    sseService.onSeriesChanged = nil
    sseService.onSeriesDeleted = nil
    sseService.onBookAdded = nil
    sseService.onBookChanged = nil
    sseService.onBookDeleted = nil
    sseService.onReadProgressChanged = nil
    sseService.onReadProgressDeleted = nil
    sseService.onReadProgressSeriesChanged = nil
    sseService.onReadProgressSeriesDeleted = nil
  }
}
