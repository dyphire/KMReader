//
//  SeriesStatus.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation
import SwiftUI

enum SeriesStatus: CaseIterable, Hashable {
  case ongoing
  case ended
  case hiatus
  case cancelled

  static func fromString(_ status: String?) -> SeriesStatus {
    guard let status = status else {
      return .ongoing
    }
    switch status.uppercased() {
    case "ONGOING":
      return .ongoing
    case "ENDED", "COMPLETED":
      return .ended
    case "HIATUS":
      return .hiatus
    case "CANCELLED":
      return .cancelled
    default:
      return .ongoing
    }
  }

  var displayName: String {
    switch self {
    case .ongoing:
      return String(localized: "series.status.ongoing")
    case .ended:
      return String(localized: "series.status.ended")
    case .hiatus:
      return String(localized: "series.status.hiatus")
    case .cancelled:
      return String(localized: "series.status.cancelled")
    }
  }

  var icon: String {
    switch self {
    case .ongoing:
      return "bolt.circle"
    case .ended:
      return "checkmark.circle"
    case .hiatus:
      return "pause.circle"
    case .cancelled:
      return "exclamationmark.circle"
    }
  }

  var apiValue: String {
    switch self {
    case .ongoing:
      return "ONGOING"
    case .ended:
      return "ENDED"
    case .hiatus:
      return "HIATUS"
    case .cancelled:
      return "CANCELLED"
    }
  }
}
