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
  case abandoned = "ABANDONED"

  static var selectableCases: [SeriesStatusFilter] {
    [.ongoing, .ended, .hiatus, .abandoned]
  }

  var displayName: String {
    switch self {
    case .all: return String(localized: "series.status.all")
    case .ongoing: return String(localized: "series.status.ongoing")
    case .ended: return String(localized: "series.status.ended")
    case .hiatus: return String(localized: "series.status.hiatus")
    case .abandoned: return String(localized: "series.status.abandoned")
    }
  }

  var apiValue: String? {
    self == .all ? nil : rawValue
  }

  static func decodeCompat(_ raw: String?) -> SeriesStatusFilter? {
    guard let raw else { return nil }
    if raw == "CANCELLED" {
      return .abandoned
    }
    return SeriesStatusFilter(rawValue: raw)
  }
}
