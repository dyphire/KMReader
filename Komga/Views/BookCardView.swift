//
//  BookCardView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

// MARK: - Book Preview Card

struct BookPreviewCard: View {
  let book: Book

  var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading, spacing: 4) {
        Text(book.metadata.title)
          .font(.headline)
          .fixedSize(horizontal: false, vertical: true)
        Text(book.seriesTitle)
          .font(.subheadline)
          .foregroundColor(.secondary)
          .fixedSize(horizontal: false, vertical: true)
        Text("#\(book.metadata.number) · \(book.media.pagesCount) pages")
          .font(.footnote)
          .foregroundColor(.secondary)
      }

      Divider()

      VStack(alignment: .leading, spacing: 8) {
        InfoRow(
          label: "SIZE",
          value: book.size,
          icon: "internaldrive"
        )

        InfoRow(
          label: "FORMAT",
          value: book.media.mediaType.uppercased(),
          icon: "doc.text"
        )

        InfoRow(
          label: "CREATED",
          value: formatDate(book.created),
          icon: "calendar.badge.plus"
        )

        InfoRow(
          label: "LAST MODIFIED",
          value: formatDate(book.lastModified),
          icon: "calendar.badge.clock"
        )

        if let authors = book.metadata.authors, !authors.isEmpty {
          InfoRow(
            label: "AUTHORS",
            value: authors.map { $0.name }.joined(separator: ", "),
            icon: "person"
          )
        }

        if let releaseDate = book.metadata.releaseDate {
          InfoRow(
            label: "RELEASE DATE",
            value: releaseDate,
            icon: "calendar"
          )
        }

        if let isbn = book.metadata.isbn, !isbn.isEmpty {
          InfoRow(
            label: "ISBN",
            value: isbn,
            icon: "barcode"
          )
        }
      }

      if let summary = book.metadata.summary, !summary.isEmpty {
        Divider()
        VStack(alignment: .leading, spacing: 4) {
          Label("SUMMARY", systemImage: "text.alignleft")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
          Text(summary)
            .font(.footnote)
            .foregroundColor(.primary)
            .lineLimit(5)
        }
      }
    }.frame(idealWidth: 320)
  }

  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
  }
}

// MARK: - Info Row

struct InfoRow: View {
  let label: String
  let value: String
  let icon: String

  var body: some View {
    HStack(alignment: .top, spacing: 8) {
      Label {
        Text(label)
          .font(.caption)
          .fontWeight(.semibold)
          .foregroundColor(.secondary)
      } icon: {
        Image(systemName: icon)
          .font(.caption)
          .foregroundColor(.secondary)
          .frame(width: 16)
      }

      Spacer()

      Text(value)
        .font(.caption)
        .foregroundColor(.primary)
        .multilineTextAlignment(.trailing)
        .lineLimit(2)
    }
  }
}

// MARK: - Book Context Menu

struct BookContextMenuModifier: ViewModifier {
  let book: Book
  let viewModel: BookViewModel
  var onNavigateToSeries: ((String) -> Void)? = nil

  private var isCompleted: Bool {
    book.readProgress?.completed ?? false
  }

  func body(content: Content) -> some View {
    content.contextMenu {
      // Mark as read
      if !isCompleted {
        Button {
          Task {
            await viewModel.markAsRead(bookId: book.id)
          }
        } label: {
          Label("Mark as Read", systemImage: "checkmark.circle")
        }
      }

      // Mark as unread
      if book.readProgress != nil {
        Button {
          Task {
            await viewModel.markAsUnread(bookId: book.id)
          }
        } label: {
          Label("Mark as Unread", systemImage: "circle")
        }
      }

      Divider()

      // Clear cache
      Button(role: .destructive) {
        Task {
          await ImageCache.clearDiskCache(forBookId: book.id)
        }
      } label: {
        Label("Clear Cache", systemImage: "trash")
      }

      // Navigate to series
      if let onNavigateToSeries = onNavigateToSeries {
        Divider()
        Button {
          onNavigateToSeries(book.seriesId)
        } label: {
          Label("Go to Series", systemImage: "book.fill")
        }
      }
    } preview: {
      BookPreviewCard(book: book).padding()
    }
  }
}

extension View {
  func bookContextMenu(
    book: Book,
    viewModel: BookViewModel,
    onNavigateToSeries: ((String) -> Void)? = nil
  ) -> some View {
    modifier(
      BookContextMenuModifier(
        book: book,
        viewModel: viewModel,
        onNavigateToSeries: onNavigateToSeries
      )
    )
  }
}

struct BookCardView: View {
  let book: Book
  var viewModel: BookViewModel
  let cardWidth: CGFloat
  var onNavigateToSeries: ((String) -> Void)? = nil
  @AppStorage("themeColorName") private var themeColorOption: ThemeColorOption = .orange

  private var thumbnailURL: URL? {
    BookService.shared.getBookThumbnailURL(id: book.id)
  }

  private var progress: Double {
    guard let readProgress = book.readProgress else { return 0 }
    guard book.media.pagesCount > 0 else { return 0 }
    return Double(readProgress.page) / Double(book.media.pagesCount)
  }

  private var isCompleted: Bool {
    book.readProgress?.completed ?? false
  }

  private var isInProgress: Bool {
    guard let readProgress = book.readProgress else { return false }
    return !readProgress.completed
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      ThumbnailImage(url: thumbnailURL, width: cardWidth)
        .overlay(alignment: .topTrailing) {
          if book.readProgress == nil {
            Circle()
              .fill(themeColorOption.color)
              .frame(width: 12, height: 12)
              .padding(4)
          }
        }
        .overlay(alignment: .topTrailing) {
          if book.readProgress == nil {
            Circle()
              .fill(themeColorOption.color)
              .frame(width: 12, height: 12)
              .padding(4)
          }
        }
        .overlay(alignment: .bottom) {
          if isInProgress {
            GeometryReader { geometry in
              ZStack(alignment: .leading) {
                Rectangle()
                  .fill(Color.gray.opacity(0.2))
                  .frame(height: 4)
                  .cornerRadius(2)

                Rectangle()
                  .fill(themeColorOption.color)
                  .frame(width: geometry.size.width * progress, height: 4)
                  .cornerRadius(2)
              }
            }
            .frame(height: 4)
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
          }
        }

      VStack(alignment: .leading, spacing: 2) {
        Text(book.seriesTitle)
          .font(.caption)
          .foregroundColor(.primary)
          .lineLimit(1)

        Text("\(book.metadata.number) - \(book.metadata.title)")
          .font(.caption)
          .foregroundColor(.primary)
          .lineLimit(1)

        Group {
          if book.deleted {
            Text("Unavailable")
              .foregroundColor(.red)
          } else {
            Text("\(book.media.pagesCount) pages · \(book.size)")
              .foregroundColor(.secondary)
              .lineLimit(1)
          }
        }.font(.caption2)
      }
      .frame(width: cardWidth, alignment: .leading)
    }
    .bookContextMenu(
      book: book,
      viewModel: viewModel,
      onNavigateToSeries: onNavigateToSeries
    )
  }
}
