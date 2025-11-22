//
//  SeriesStatusFilter.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation

enum SeriesStatusFilter: String, CaseIterable {
  case all = "ALL"
  case ongoing = "ONGOING"
  case ended = "ENDED"
  case hiatus = "HIATUS"
  case cancelled = "CANCELLED"

  var displayName: String {
    switch self {
    case .all: return "All"
    case .ongoing: return "Ongoing"
    case .ended: return "Ended"
    case .hiatus: return "Hiatus"
    case .cancelled: return "Cancelled"
    }
  }
}
