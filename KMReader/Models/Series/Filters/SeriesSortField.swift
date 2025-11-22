//
//  SeriesSortField.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation

enum SeriesSortField: String, CaseIterable {
  case name = "metadata.titleSort"
  case dateAdded = "created"
  case dateUpdated = "lastModified"
  case dateRead = "fileLastModified"
  case releaseDate = "booksMetadata.releaseDate"
  case folderName = "metadata.title"
  case booksCount = "booksCount"
  case random = "random"

  var displayName: String {
    switch self {
    case .name: return "Name"
    case .dateAdded: return "Date Added"
    case .dateUpdated: return "Date Updated"
    case .dateRead: return "Date Read"
    case .releaseDate: return "Release Date"
    case .folderName: return "Folder Name"
    case .booksCount: return "Books Count"
    case .random: return "Random"
    }
  }

  var supportsDirection: Bool {
    return self != .random
  }
}
