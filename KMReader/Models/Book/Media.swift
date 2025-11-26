//
//  Media.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation

enum MediaProfile: String, Codable {
  case divina = "DIVINA"
  case pdf = "PDF"
  case epub = "EPUB"
  case unknown = ""
}

enum MediaStatus: String, Codable {
  case ready = "READY"
  case unknown = "UNKNOWN"
  case error = "ERROR"
  case unsupported = "UNSUPPORTED"
  case outdated = "OUTDATED"

  var message: String {
    switch self {
    case .ready:
      return ""
    case .error:
      return "Failed to load media"
    case .unsupported:
      return "Media format is not supported"
    case .outdated:
      return "Media is outdated"
    case .unknown:
      return "Media status is unknown"
    }
  }

  var icon: String {
    switch self {
    case .ready:
      return ""
    case .error:
      return "exclamationmark.triangle"
    case .unsupported:
      return "xmark.circle"
    case .outdated:
      return "clock.badge.exclamationmark"
    case .unknown:
      return "questionmark.circle"
    }
  }
}

struct Media: Codable, Equatable {
  let status: MediaStatus
  let mediaType: String
  let pagesCount: Int
  let comment: String?
  let mediaProfile: MediaProfile?
  let epubDivinaCompatible: Bool?
  let epubIsKepub: Bool?
}
