//
//  BrowseView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct BrowseView: View {
  @AppStorage("selectedLibraryId") private var selectedLibraryId: String = ""
  @AppStorage("browseOptions") private var browseOpts: BrowseOptions = BrowseOptions()
  @AppStorage("browseContent") private var browseContent: BrowseContentType = .series
  @AppStorage("browseLayout") private var browseLayout: BrowseLayoutMode = .grid
  @State private var showLibraryPickerSheet = false
  @State private var searchQuery: String = ""

  var body: some View {
    NavigationStack {
      GeometryReader { geometry in
        ScrollView {
          VStack(spacing: 0) {
            Picker("Content Type", selection: $browseContent) {
              ForEach(BrowseContentType.allCases) { type in
                Text(type.displayName).tag(type)
              }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            contentView(for: geometry.size)
          }
        }
        .handleNavigation()
        .navigationTitle("Browse")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button {
              showLibraryPickerSheet = true
            } label: {
              Image(systemName: "books.vertical")
            }
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
              Picker("Layout", selection: $browseLayout) {
                ForEach(BrowseLayoutMode.allCases) { mode in
                  Label(mode.displayName, systemImage: mode.iconName).tag(mode)
                }
              }
              .pickerStyle(.inline)
            } label: {
              Image(systemName: browseLayout.iconName)
            }
          }
        }
        .sheet(isPresented: $showLibraryPickerSheet) {
          LibraryPickerSheet()
        }
        .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .automatic))
        .onChange(of: selectedLibraryId) { _, newValue in
          browseOpts.libraryId = newValue
        }
        .onAppear {
          browseOpts.libraryId = selectedLibraryId
        }
      }
    }
  }

  @ViewBuilder
  private func contentView(for size: CGSize) -> some View {
    let searchText = searchQuery
    switch browseContent {
    case .series:
      SeriesBrowseView(
        browseOpts: $browseOpts,
        width: size.width,
        height: size.height,
        searchText: searchText
      )
    case .books:
      BooksBrowseView(
        browseOpts: $browseOpts,
        width: size.width,
        height: size.height,
        searchText: searchText
      )
    case .collections:
      CollectionsBrowseView(
        browseOpts: $browseOpts,
        width: size.width,
        height: size.height,
        searchText: searchText
      )
    case .readlists:
      ReadListsBrowseView(
        browseOpts: $browseOpts,
        width: size.width,
        height: size.height,
        searchText: searchText
      )
    }
  }
}

struct BrowseOptionsSheet: View {
  @Binding var browseOpts: BrowseOptions
  let contentType: BrowseContentType
  @Environment(\.dismiss) private var dismiss
  @State private var tempOpts: BrowseOptions

  init(browseOpts: Binding<BrowseOptions>, contentType: BrowseContentType) {
    self._browseOpts = browseOpts
    self.contentType = contentType
    self._tempOpts = State(initialValue: browseOpts.wrappedValue)
  }

  var body: some View {
    NavigationStack {
      Form {
        if contentType.supportsReadStatusFilter || contentType.supportsSeriesStatusFilter {
          Section("Filters") {
            if contentType.supportsReadStatusFilter {
              Picker("Read Status", selection: $tempOpts.readStatusFilter) {
                ForEach(ReadStatusFilter.allCases, id: \.self) { filter in
                  Text(filter.displayName).tag(filter)
                }
              }
              .pickerStyle(.menu)
            }

            if contentType.supportsSeriesStatusFilter {
              Picker("Series Status", selection: $tempOpts.seriesStatusFilter) {
                ForEach(SeriesStatusFilter.allCases, id: \.self) { filter in
                  Text(filter.displayName).tag(filter)
                }
              }
              .pickerStyle(.menu)
            }
          }
        }

        if contentType.supportsSorting {
          Section("Sort") {
            Picker("Sort By", selection: $tempOpts.sortField) {
              ForEach(SeriesSortField.allCases, id: \.self) { field in
                Text(field.displayName).tag(field)
              }
            }
            .pickerStyle(.menu)

            if tempOpts.sortField.supportsDirection {
              Picker("Direction", selection: $tempOpts.sortDirection) {
                ForEach(SortDirection.allCases, id: \.self) { direction in
                  HStack {
                    Image(systemName: direction.icon)
                    Text(direction.displayName)
                  }
                  .tag(direction)
                }
              }
              .pickerStyle(.menu)
            }
          }
        }
      }
      .navigationTitle("Filter & Sort")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            // Only assign if there are changes
            if tempOpts != browseOpts {
              browseOpts = tempOpts
            }
            dismiss()
          } label: {
            Label("Done", systemImage: "checkmark")
          }
        }
      }
    }
  }
}

struct LibraryPickerSheet: View {
  @AppStorage("selectedLibraryId") private var selectedLibraryId: String = ""
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      Form {
        Picker("Library", selection: $selectedLibraryId) {
          Label("All Libraries", systemImage: "square.grid.2x2").tag("")
          ForEach(LibraryManager.shared.libraries) { library in
            Label(library.name, systemImage: "books.vertical").tag(library.id)
          }
        }
        .pickerStyle(.inline)
      }
      .navigationTitle("Select Library")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            dismiss()
          } label: {
            Label("Done", systemImage: "checkmark")
          }
        }
      }
      .onChange(of: selectedLibraryId) { oldValue, newValue in
        // Dismiss when user selects a different library
        if oldValue != newValue {
          dismiss()
        }
      }
    }
  }
}
