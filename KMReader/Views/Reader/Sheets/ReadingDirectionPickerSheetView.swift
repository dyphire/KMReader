//
//  ReadingDirectionPickerSheetView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct ReadingDirectionPickerSheetView: View {
  @Binding var readingDirection: ReadingDirection

  @AppStorage("themeColorName") private var themeColorOption: ThemeColorOption = .orange

  var body: some View {
    NavigationStack {
      Form {
        Picker("Reading Direction", selection: $readingDirection) {
          ForEach(ReadingDirection.allCases, id: \.self) { direction in
            HStack(spacing: 12) {
              Image(systemName: direction.icon)
                .foregroundStyle(themeColorOption.color)
              Text(direction.displayName)
            }
            .tag(direction)
          }
        }.pickerStyle(.inline)
      }
      .navigationTitle("Reading Mode")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}
