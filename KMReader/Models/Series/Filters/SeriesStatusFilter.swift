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
    case .all: return String(localized: "series.status.all")
    case .ongoing: return String(localized: "series.status.ongoing")
    case .ended: return String(localized: "series.status.ended")
    case .hiatus: return String(localized: "series.status.hiatus")
    case .cancelled: return String(localized: "series.status.cancelled")
    }
  }
}
