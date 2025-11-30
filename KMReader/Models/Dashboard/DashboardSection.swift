//
//  DashboardSection.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation

enum DashboardSection: String, CaseIterable, Identifiable, Codable {
  case keepReading = "keepReading"
  case onDeck = "onDeck"
  case recentlyReleasedBooks = "recentlyReleasedBooks"
  case recentlyAddedBooks = "recentlyAddedBooks"
  case recentlyAddedSeries = "recentlyAddedSeries"
  case recentlyUpdatedSeries = "recentlyUpdatedSeries"
  case recentlyReadBooks = "recentlyReadBooks"

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .keepReading:
      return "Keep Reading"
    case .onDeck:
      return "On Deck"
    case .recentlyReleasedBooks:
      return "Recently Released Books"
    case .recentlyAddedBooks:
      return "Recently Added Books"
    case .recentlyUpdatedSeries:
      return "Recently Updated Series"
    case .recentlyAddedSeries:
      return "Recently Added Series"
    case .recentlyReadBooks:
      return "Recently Read Books"
    }
  }

  var icon: String {
    switch self {
    case .keepReading:
      return "book.fill"
    case .onDeck:
      return "bookmark.fill"
    case .recentlyReleasedBooks:
      return "calendar.badge.clock"
    case .recentlyAddedBooks:
      return "sparkles"
    case .recentlyUpdatedSeries:
      return "arrow.triangle.2.circlepath.circle.fill"
    case .recentlyAddedSeries:
      return "square.stack.3d.up.fill"
    case .recentlyReadBooks:
      return "checkmark.circle.fill"
    }
  }
}
