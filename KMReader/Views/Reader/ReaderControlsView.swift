//
//  ReaderControlsView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI
import UniformTypeIdentifiers

struct ReaderControlsView: View {
  @Binding var showingControls: Bool
  @Binding var showingReadingDirectionPicker: Bool
  @Binding var readingDirection: ReadingDirection
  let viewModel: ReaderViewModel
  let currentBook: Book?
  let dualPage: Bool
  let onDismiss: () -> Void

  @AppStorage("themeColorHex") private var themeColor: ThemeColor = .orange

  @State private var saveImageResult: SaveImageResult?
  @State private var showSaveAlert = false
  @State private var showDocumentPicker = false
  @State private var fileToSave: URL?
  @State private var showingPageJumpSheet = false
  @State private var showingTOCSheet = false

  enum SaveImageResult: Equatable {
    case success
    case failure(String)
  }

  private var displayedCurrentPage: String {
    guard viewModel.pages.count > 0 else { return "0" }
    if viewModel.currentPageIndex >= viewModel.pages.count {
      return "END"
    } else {
      if dualPage, let pair = viewModel.dualPageIndices[viewModel.currentPageIndex] {
        return pair.display
      } else {
        return String(viewModel.currentPageIndex + 1)
      }
    }
  }

  private func jumpToPage(page: Int) {
    guard !viewModel.pages.isEmpty else { return }
    let clampedPage = min(max(page, 1), viewModel.pages.count)
    let targetIndex = clampedPage - 1
    if targetIndex != viewModel.currentPageIndex {
      viewModel.targetPageIndex = targetIndex
    }
  }

  private func jumpToTOCEntry(_ entry: ReaderTOCEntry) {
    jumpToPage(page: entry.pageIndex + 1)
  }

  var body: some View {
    VStack {
      // Top bar
      VStack(spacing: 12) {

        // Close button and action buttons
        HStack {
          Button {
            onDismiss()
          } label: {
            Image(systemName: "xmark")
              .foregroundColor(.white)
              .frame(minWidth: 40, minHeight: 40)
              .padding(6)
              .background(themeColor.color.opacity(0.9))
              .clipShape(Circle())
              .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
          }

          Spacer()

          // Action buttons
          HStack(spacing: 12) {
            // TOC button (only show if TOC exists)
            if !viewModel.tableOfContents.isEmpty {
              Button {
                showingTOCSheet = true
              } label: {
                Image(systemName: "list.bullet.rectangle.portrait")
                  .foregroundColor(.white)
                  .frame(width: 40, height: 40)
                  .padding(6)
                  .background(themeColor.color.opacity(0.9))
                  .clipShape(Circle())
                  .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
              }
            }

            // Jump to page button
            Button {
              guard !viewModel.pages.isEmpty else { return }
              showingPageJumpSheet = true
            } label: {
              Image(systemName: "photo.stack")
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .padding(6)
                .background(themeColor.color.opacity(0.9))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            }

            // Reading direction button
            Button {
              showingReadingDirectionPicker = true
            } label: {
              Image(systemName: readingDirection.icon)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .padding(6)
                .background(themeColor.color.opacity(0.9))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
          }

        }.buttonStyle(.plain)
      }
      .padding()
      .allowsHitTesting(true)

      // Series and book title
      if let book = currentBook {
        VStack(spacing: 4) {
          Text(book.seriesTitle)
            .font(.headline)
            .foregroundColor(.white)
          Text("#\(Int(book.number)) - \(book.metadata.title)")
            .font(.subheadline)
            .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(themeColor.color.opacity(0.9))
        .cornerRadius(12)
      }

      Spacer()

      // Bottom section with page info and slider
      VStack(spacing: 12) {
        // Page info display
        HStack(spacing: 6) {
          Image(systemName: "bookmark")
            .font(.footnote)
          Text("\(displayedCurrentPage) / \(viewModel.pages.count)")
            .monospacedDigit()
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(themeColor.color.opacity(0.9))
        .cornerRadius(20)
        .overlay(
          RoundedRectangle(cornerRadius: 20)
            .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

        // Bottom slider
        ProgressView(
          value: Double(min(viewModel.currentPageIndex + 1, viewModel.pages.count)),
          total: Double(viewModel.pages.count)
        )
        .scaleEffect(x: readingDirection == .rtl ? -1 : 1, y: 1)
      }
      .padding()
    }
    .padding(.vertical)
    .allowsHitTesting(true)
    .transition(.opacity)
    .onChange(of: readingDirection) { _, _ in
      if showingReadingDirectionPicker {
        showingReadingDirectionPicker = false
      }
    }
    .sheet(isPresented: $showingPageJumpSheet) {
      PageJumpSheetView(
        bookId: viewModel.bookId,
        totalPages: viewModel.pages.count,
        currentPage: min(viewModel.currentPageIndex + 1, viewModel.pages.count),
        readingDirection: readingDirection,
        onJump: jumpToPage
      )
    }
    .sheet(isPresented: $showingReadingDirectionPicker) {
      ReadingDirectionPickerSheetView(readingDirection: $readingDirection)
        .presentationDetents([.height(400)])
        .presentationDragIndicator(.visible)
    }
    .sheet(isPresented: $showingTOCSheet) {
      ReaderTOCSheetView(
        entries: viewModel.tableOfContents,
        currentPageIndex: viewModel.currentPageIndex,
        onSelect: { entry in
          showingTOCSheet = false
          jumpToTOCEntry(entry)
        }
      )
    }
  }
}
