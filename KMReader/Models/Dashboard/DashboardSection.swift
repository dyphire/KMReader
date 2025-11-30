//
//  DashboardSection.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation
import SwiftUI

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

// RawRepresentable wrapper for [DashboardSection] to use with @AppStorage
struct DashboardConfiguration: Equatable, RawRepresentable {
  typealias RawValue = String

  var sections: [DashboardSection]

  init(sections: [DashboardSection] = DashboardSection.allCases) {
    self.sections = sections
  }

  var rawValue: String {
    let stringArray = sections.map { $0.rawValue }
    if let data = try? JSONSerialization.data(withJSONObject: stringArray),
      let json = String(data: data, encoding: .utf8)
    {
      return json
    }
    return "[]"
  }

  init?(rawValue: String) {
    guard !rawValue.isEmpty else {
      self.sections = DashboardSection.allCases
      return
    }
    guard let data = rawValue.data(using: .utf8),
      let stringArray = try? JSONSerialization.jsonObject(with: data) as? [String]
    else {
      self.sections = DashboardSection.allCases
      return
    }
    self.sections = stringArray.compactMap { DashboardSection(rawValue: $0) }
    // If no valid sections found, use default
    if self.sections.isEmpty {
      self.sections = DashboardSection.allCases
    }
  }
}
