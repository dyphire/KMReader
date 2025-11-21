//
//  ReadListsBrowseView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct ReadListsBrowseView: View {
  @Binding var browseOpts: BrowseOptions
  let width: CGFloat
  let height: CGFloat
  let searchText: String

  private let spacing: CGFloat = 16

  @AppStorage("themeColorName") private var themeColorOption: ThemeColorOption = .orange
  @AppStorage("browseColumns") private var browseColumns: BrowseColumns = BrowseColumns()
  @AppStorage("browseLayout") private var browseLayout: BrowseLayoutMode = .grid
  @State private var viewModel = ReadListViewModel()
  @State private var showOptions = false

  private var availableWidth: CGFloat {
    width - spacing * 2
  }

  private var isLandscape: Bool {
    width > height
  }

  private var columnsCount: Int {
    isLandscape ? browseColumns.landscape : browseColumns.portrait
  }

  private var cardWidth: CGFloat {
    guard columnsCount > 0 else { return availableWidth }
    let totalSpacing = CGFloat(columnsCount - 1) * spacing
    return (availableWidth - totalSpacing) / CGFloat(columnsCount)
  }

  private var columns: [GridItem] {
    Array(repeating: GridItem(.fixed(cardWidth), spacing: spacing), count: max(columnsCount, 1))
  }

  var body: some View {
    VStack(spacing: 0) {
      if BrowseContentType.readlists.supportsSorting
        || BrowseContentType.readlists.supportsReadStatusFilter
      {
        header
      }
      if viewModel.isLoading && viewModel.readLists.isEmpty {
        ProgressView()
          .frame(maxWidth: .infinity)
          .padding()
      } else if let errorMessage = viewModel.errorMessage {
        VStack(spacing: 16) {
          Image(systemName: "exclamationmark.triangle")
            .font(.largeTitle)
            .foregroundColor(themeColorOption.color)
          Text(errorMessage)
            .multilineTextAlignment(.center)
          Button("Retry") {
            Task {
              await loadReadLists(refresh: true)
            }
          }
        }
        .padding()
      } else if viewModel.readLists.isEmpty {
        VStack(spacing: 12) {
          Image(systemName: "list.bullet.rectangle")
            .font(.system(size: 40))
            .foregroundColor(.secondary)
          Text("No read lists found")
            .font(.headline)
          Text("Try selecting a different library.")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
      } else {
        switch browseLayout {
        case .grid:
          LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(Array(viewModel.readLists.enumerated()), id: \.element.id) { index, readList in
              ReadListCardView(readList: readList, width: cardWidth)
                .onAppear {
                  if index >= viewModel.readLists.count - 3 {
                    Task {
                      await loadReadLists(refresh: false)
                    }
                  }
                }
            }
          }
          .padding(.horizontal, spacing)
        case .list:
          LazyVStack(spacing: 0) {
            ForEach(Array(viewModel.readLists.enumerated()), id: \.element.id) { index, readList in
              ReadListRowView(readList: readList)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .onAppear {
                  if index >= viewModel.readLists.count - 3 {
                    Task {
                      await loadReadLists(refresh: false)
                    }
                  }
                }

              if index < viewModel.readLists.count - 1 {
                Divider()
                  .padding(.leading)
              }
            }
          }
        }

        if viewModel.isLoading {
          ProgressView()
            .padding()
        }
      }
    }
    .task {
      if viewModel.readLists.isEmpty {
        await loadReadLists(refresh: true)
      }
    }
    .onChange(of: browseOpts) { _, _ in
      Task {
        await loadReadLists(refresh: true)
      }
    }
    .onChange(of: searchText) { _, _ in
      Task {
        await loadReadLists(refresh: true)
      }
    }
    .sheet(isPresented: $showOptions) {
      BrowseOptionsSheet(browseOpts: $browseOpts, contentType: .readlists)
    }
  }

  private func loadReadLists(refresh: Bool) async {
    let sort = browseOpts.sortString(for: .readlists)
    await viewModel.loadReadLists(
      libraryId: browseOpts.libraryId,
      sort: sort,
      searchText: searchText,
      refresh: refresh
    )
  }
}

extension ReadListsBrowseView {
  private var header: some View {
    HStack {
      Button {
        showOptions = true
      } label: {
        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
      }
    }
    .frame(maxWidth: .infinity, alignment: .trailing)
    .padding([.horizontal, .top])
  }
}
