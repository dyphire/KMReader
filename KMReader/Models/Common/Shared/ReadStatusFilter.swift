//
//  ReadStatusFilter.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation

/// Filter for read status (used by both Book and Series)
enum ReadStatusFilter: String, CaseIterable {
  case all = "ALL"
  case read = "READ"
  case unread = "UNREAD"
  case inProgress = "IN_PROGRESS"

  var displayName: String {
    switch self {
    case .all: return String(localized: "readStatus.all")
    case .read: return String(localized: "readStatus.read")
    case .unread: return String(localized: "readStatus.unread")
    case .inProgress: return String(localized: "readStatus.inProgress")
    }
  }
}
