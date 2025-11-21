//
//  BrowseView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct BrowseView: View {
  @AppStorage("selectedLibraryId") private var selectedLibraryId: String = ""
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
      }
    }
  }

  @ViewBuilder
  private func contentView(for size: CGSize) -> some View {
    let searchText = searchQuery
    switch browseContent {
    case .series:
      SeriesBrowseView(
        width: size.width,
        height: size.height,
        searchText: searchText
      )
    case .books:
      BooksBrowseView(
        width: size.width,
        height: size.height,
        searchText: searchText
      )
    case .collections:
      CollectionsBrowseView(
        width: size.width,
        height: size.height,
        searchText: searchText
      )
    case .readlists:
      ReadListsBrowseView(
        width: size.width,
        height: size.height,
        searchText: searchText
      )
    }
  }
}
