//
//  ReaderControlsView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct ReaderControlsView: View {
  @Binding var showingControls: Bool
  @Binding var showingReadingDirectionPicker: Bool
  let viewModel: ReaderViewModel
  let currentBook: Book?
  let themeColorOption: ThemeColorOption
  let onDismiss: () -> Void

  var body: some View {
    VStack {
      // Top bar
      VStack(spacing: 8) {
        HStack {
          Button {
            onDismiss()
          } label: {
            Image(systemName: "xmark")
              .font(.title2)
              .foregroundColor(.white)
              .padding()
              .background(themeColorOption.color.opacity(0.8))
              .clipShape(Circle())
          }
          .frame(minWidth: 44, minHeight: 44)
          .contentShape(Rectangle())

          Spacer()

          // Page count in the middle
          Text("\(viewModel.currentPage + 1) / \(viewModel.pages.count)")
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(themeColorOption.color.opacity(0.8))
            .cornerRadius(20)

          Spacer()

          // Display mode toggle button
          Button {
            showingReadingDirectionPicker = true
          } label: {
            Image(systemName: viewModel.readingDirection.icon)
              .font(.title3)
              .foregroundColor(.white)
              .padding()
              .background(themeColorOption.color.opacity(0.8))
              .clipShape(Circle())
          }
          .frame(minWidth: 44, minHeight: 44)
          .contentShape(Rectangle())
        }
        .padding(.horizontal)
      }
      .padding(.top)
      .allowsHitTesting(true)

      // Series and book title
      if let book = currentBook {
        VStack(spacing: 4) {
          Text(book.seriesTitle)
            .font(.headline)
            .foregroundColor(.white)
          Text("#\(Int(book.number)) - \(book.metadata.title)")
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(themeColorOption.color.opacity(0.8))
        .cornerRadius(12)
      }

      Spacer()

      // Bottom slider
      VStack {
        ProgressView(
          value: Double(min(viewModel.currentPage + 1, viewModel.pages.count)),
          total: Double(viewModel.pages.count)
        )
      }
      .padding()
    }
    .allowsHitTesting(true)
    .transition(.opacity)
  }
}
