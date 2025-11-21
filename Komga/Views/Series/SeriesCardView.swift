//
//  SeriesCardView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct SeriesCardView: View {
  let series: Series
  let cardWidth: CGFloat
  var onActionCompleted: (() -> Void)? = nil

  @AppStorage("showSeriesCardTitle") private var showTitle: Bool = true

  @State private var actionErrorMessage: String?

  private var isActionErrorPresented: Binding<Bool> {
    Binding(
      get: { actionErrorMessage != nil },
      set: { if !$0 { actionErrorMessage = nil } }
    )
  }

  private var thumbnailURL: URL? {
    SeriesService.shared.getSeriesThumbnailURL(id: series.id)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      ThumbnailImage(url: thumbnailURL, width: cardWidth)
        .overlay(alignment: .topTrailing) {
          if series.booksUnreadCount > 0 {
            UnreadCountBadge(count: series.booksUnreadCount)
              .padding(4)
          }
        }

      VStack(alignment: .leading, spacing: 2) {
        if showTitle {
          Text(series.metadata.title)
            .font(.caption)
            .foregroundColor(.primary)
            .lineLimit(1)
        }
        Group {
          if series.deleted {
            Text("Unavailable")
              .foregroundColor(.red)
          } else {
            HStack(spacing: 4) {
              Text("\(series.booksCount) books")
              if series.oneshot {
                Text("•")
                Text("Oneshot")
                  .foregroundColor(.blue)
              }
            }
            .foregroundColor(.secondary)
          }
        }.font(.caption2)
      }
      .frame(width: cardWidth, alignment: .leading)
    }
    .contentShape(Rectangle())
    .contextMenu {
      SeriesContextMenu(
        series: series,
        onActionCompleted: onActionCompleted,
        onActionFailed: { message in
          actionErrorMessage = message
        }
      )
    }
    .alert("Action Failed", isPresented: isActionErrorPresented) {
      Button("OK", role: .cancel) {}
    } message: {
      if let message = actionErrorMessage {
        Text(message)
      }
    }
  }
}
