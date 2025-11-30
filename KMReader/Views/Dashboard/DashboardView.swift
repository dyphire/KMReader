//
//  DashboardView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Combine
import SwiftUI

struct DashboardView: View {
  @State private var sectionData: [DashboardSection: Any] = [:]
  @State private var isLoading = false

  @State private var bookViewModel = BookViewModel()
  @State private var seriesViewModel = SeriesViewModel()

  @AppStorage("selectedLibraryId") private var selectedLibraryId: String = ""
  @AppStorage("themeColorHex") private var themeColor: ThemeColor = .orange

  private var visibleSections: [DashboardSection] {
    return AppConfig.dashboardSections
  }

  private var hasContent: Bool {
    return visibleSections.contains { section in
      switch section {
      case .keepReading, .onDeck, .recentlyReadBooks, .recentlyReleasedBooks, .recentlyAddedBooks:
        if let books = sectionData[section] as? [Book] {
          return !books.isEmpty
        }
        return false
      case .recentlyUpdatedSeries, .recentlyAddedSeries:
        if let series = sectionData[section] as? [Series] {
          return !series.isEmpty
        }
        return false
      }
    }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          if !hasContent {
            if isLoading {
              ProgressView()
                .frame(maxWidth: .infinity)
                .padding()
                .transition(.opacity)
            } else {
              VStack(spacing: 16) {
                Image(systemName: "book")
                  .font(.system(size: 60))
                  .foregroundColor(.secondary)
                Text("Nothing to show")
                  .font(.headline)
                Text("Start reading to see recommendations here")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                  .multilineTextAlignment(.center)
              }
              .frame(maxWidth: .infinity)
              .padding()
              .transition(.opacity)
            }
          } else {
            ForEach(visibleSections, id: \.id) { section in
              if let books = sectionData[section] as? [Book], !books.isEmpty {
                DashboardBooksSection(
                  title: section.displayName,
                  books: books,
                  bookViewModel: bookViewModel,
                  onBookUpdated: refreshDashboardData
                )
                .transition(.move(edge: .top).combined(with: .opacity))
              } else if let series = sectionData[section] as? [Series], !series.isEmpty {
                DashboardSeriesSection(
                  title: section.displayName,
                  series: series,
                  seriesViewModel: seriesViewModel,
                  onSeriesUpdated: refreshDashboardData
                )
                .transition(.move(edge: .top).combined(with: .opacity))
              }
            }
          }
        }
        .padding(.vertical)
      }
      .handleNavigation()
      .inlineNavigationBarTitle("Dashboard")
      #if !os(tvOS)
        .toolbar {
          ToolbarItem(placement: .automatic) {
            Button {
              Task {
                await loadAll()
              }
            } label: {
              Image(systemName: "arrow.clockwise.circle")
            }
            .disabled(isLoading)
          }
        }
      #endif
      .onChange(of: selectedLibraryId) {
        Task {
          await loadAll()
        }
      }
    }
    .task {
      await loadAll()
    }
    .onAppear {
      // Refresh when view appears (e.g., returning from settings)
      Task {
        await loadAll()
      }
    }
  }

  private func loadAll() async {
    isLoading = true

    let sectionsToLoad = visibleSections
    await withTaskGroup(of: Void.self) { group in
      for section in sectionsToLoad {
        group.addTask {
          await self.loadSection(section)
        }
      }
    }

    isLoading = false
  }

  private func loadSection(_ section: DashboardSection) async {
    switch section {
    case .keepReading:
      await loadKeepReading()
    case .onDeck:
      await loadOnDeck()
    case .recentlyReadBooks:
      await loadRecentlyReadBooks()
    case .recentlyReleasedBooks:
      await loadRecentlyReleasedBooks()
    case .recentlyAddedBooks:
      await loadRecentlyAddedBooks()
    case .recentlyAddedSeries:
      await loadRecentlyAddedSeries()
    case .recentlyUpdatedSeries:
      await loadRecentlyUpdatedSeries()
    }
  }

  private func loadKeepReading() async {
    do {
      // Load books with IN_PROGRESS read status
      let condition = BookSearch.buildCondition(
        libraryId: selectedLibraryId.isEmpty ? nil : selectedLibraryId,
        readStatus: ReadStatus.inProgress
      )

      let search = BookSearch(condition: condition)

      let page = try await BookService.shared.getBooksList(
        search: search,
        size: 20,
        sort: "readProgress.readDate,desc"
      )
      withAnimation {
        sectionData[.keepReading] = page.content
      }
    } catch {
      ErrorManager.shared.alert(error: error)
    }
  }

  private func loadOnDeck() async {
    do {
      let page = try await BookService.shared.getBooksOnDeck(
        libraryId: selectedLibraryId, size: 20)
      withAnimation {
        sectionData[.onDeck] = page.content
      }
    } catch {
      ErrorManager.shared.alert(error: error)
    }
  }

  private func loadRecentlyReadBooks() async {
    do {
      let page = try await BookService.shared.getRecentlyReadBooks(
        libraryId: selectedLibraryId, size: 20)
      withAnimation {
        sectionData[.recentlyReadBooks] = page.content
      }
    } catch {
      ErrorManager.shared.alert(error: error)
    }
  }

  private func loadRecentlyReleasedBooks() async {
    do {
      let page = try await BookService.shared.getRecentlyReleasedBooks(
        libraryId: selectedLibraryId, size: 20)
      // Filter out books without release dates
      let booksWithReleaseDate = page.content.filter {
        $0.metadata.releaseDate != nil && !$0.metadata.releaseDate!.isEmpty
      }
      withAnimation {
        sectionData[.recentlyReleasedBooks] = booksWithReleaseDate
      }
    } catch {
      ErrorManager.shared.alert(error: error)
    }
  }

  private func loadRecentlyAddedBooks() async {
    do {
      let page = try await BookService.shared.getRecentlyAddedBooks(
        libraryId: selectedLibraryId, size: 20)
      withAnimation {
        sectionData[.recentlyAddedBooks] = page.content
      }
    } catch {
      ErrorManager.shared.alert(error: error)
    }
  }

  private func loadRecentlyAddedSeries() async {
    await seriesViewModel.loadNewSeries(libraryId: selectedLibraryId)
    withAnimation {
      sectionData[.recentlyAddedSeries] = seriesViewModel.series
    }
  }

  private func loadRecentlyUpdatedSeries() async {
    await seriesViewModel.loadUpdatedSeries(libraryId: selectedLibraryId)
    withAnimation {
      sectionData[.recentlyUpdatedSeries] = seriesViewModel.series
    }
  }

  private func refreshDashboardData() {
    Task {
      await loadAll()
    }
  }
}

#Preview {
  DashboardView()
}
