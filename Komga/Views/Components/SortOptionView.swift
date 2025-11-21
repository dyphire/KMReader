//
//  SortOptionView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct SortOptionView<SortField: SortFieldProtocol>: View {
  @Binding var sortField: SortField
  @Binding var sortDirection: SortDirection

  var body: some View {
    Section("Sort") {
      Picker("Sort By", selection: $sortField) {
        ForEach(SortField.allCases, id: \.self) { field in
          Text(field.displayName).tag(field)
        }
      }
      .pickerStyle(.menu)

      if sortField.supportsDirection {
        Picker("Direction", selection: $sortDirection) {
          ForEach(Array(SortDirection.allCases), id: \.self) { direction in
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
