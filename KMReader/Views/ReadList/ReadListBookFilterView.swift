//
//  ReadListBookFilterView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct ReadListBookFilterView: View {
  @Binding var browseOpts: ReadListBookBrowseOptions
  @Binding var showFilterSheet: Bool

  var body: some View {
    HStack(spacing: 8) {
      LayoutModePicker()

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 6) {
          Image(systemName: "line.3.horizontal.decrease.circle")
            .padding(.leading, 4)

          Button {
            showFilterSheet = true
          } label: {
            FilterChip(
              label: browseOpts.readStatusFilter != .all
                ? "Read: \(browseOpts.readStatusFilter.displayName)"
                : "Filter",
              systemImage: "eye"
            )
          }
          .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
      }

      Spacer()
    }
    .sheet(isPresented: $showFilterSheet) {
      ReadListBookBrowseOptionsSheet(browseOpts: $browseOpts)
    }
  }
}
