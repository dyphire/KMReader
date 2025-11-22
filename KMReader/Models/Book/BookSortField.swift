//
//  BookSortField.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation

// Sort field enum for Books
enum BookSortField: String, CaseIterable {
  case series = "series,metadata.numberSort"
  case name = "metadata.title"
  case dateAdded = "createdDate"
  case dateUpdated = "lastModifiedDate"
  case releaseDate = "metadata.releaseDate"
  case dateRead = "readProgress.readDate"
  case fileSize = "fileSize"
  case fileName = "name"
  case pageCount = "media.pagesCount"

  var displayName: String {
    switch self {
    case .series: return "Series"
    case .name: return "Name"
    case .dateAdded: return "Date Added"
    case .dateUpdated: return "Date Updated"
    case .releaseDate: return "Release Date"
    case .dateRead: return "Date Read"
    case .fileSize: return "File Size"
    case .fileName: return "File Name"
    case .pageCount: return "Page Count"
    }
  }

  var supportsDirection: Bool {
    return true
  }
}
