//
//  SeriesSortOption.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation

// Legacy enum for backward compatibility - converts to new format
enum SeriesSortOption: String, CaseIterable {
  case nameAsc = "metadata.titleSort,asc"
  case nameDesc = "metadata.titleSort,desc"
  case dateAddedAsc = "created,asc"
  case dateAddedDesc = "created,desc"
  case dateUpdatedAsc = "lastModified,asc"
  case dateUpdatedDesc = "lastModified,desc"
  case dateReadAsc = "fileLastModified,asc"
  case dateReadDesc = "fileLastModified,desc"
  case releaseDateAsc = "booksMetadata.releaseDate,asc"
  case releaseDateDesc = "booksMetadata.releaseDate,desc"
  case folderNameAsc = "metadata.title,asc"
  case folderNameDesc = "metadata.title,desc"
  case booksCountAsc = "booksCount,asc"
  case booksCountDesc = "booksCount,desc"
  case random = "random"

  var displayName: String {
    switch self {
    case .nameAsc: return "Name (A-Z)"
    case .nameDesc: return "Name (Z-A)"
    case .dateAddedAsc: return "Date Added (Oldest)"
    case .dateAddedDesc: return "Date Added (Newest)"
    case .dateUpdatedAsc: return "Date Updated (Oldest)"
    case .dateUpdatedDesc: return "Date Updated (Newest)"
    case .dateReadAsc: return "Date Read (Oldest)"
    case .dateReadDesc: return "Date Read (Newest)"
    case .releaseDateAsc: return "Release Date (Oldest)"
    case .releaseDateDesc: return "Release Date (Newest)"
    case .folderNameAsc: return "Folder Name (A-Z)"
    case .folderNameDesc: return "Folder Name (Z-A)"
    case .booksCountAsc: return "Books Count (Fewest)"
    case .booksCountDesc: return "Books Count (Most)"
    case .random: return "Random"
    }
  }

  var sortField: SeriesSortField {
    switch self {
    case .nameAsc, .nameDesc: return .name
    case .dateAddedAsc, .dateAddedDesc: return .dateAdded
    case .dateUpdatedAsc, .dateUpdatedDesc: return .dateUpdated
    case .dateReadAsc, .dateReadDesc: return .dateRead
    case .releaseDateAsc, .releaseDateDesc: return .releaseDate
    case .folderNameAsc, .folderNameDesc: return .folderName
    case .booksCountAsc, .booksCountDesc: return .booksCount
    case .random: return .random
    }
  }

  var sortDirection: SortDirection {
    switch self {
    case .nameAsc, .dateAddedAsc, .dateUpdatedAsc, .dateReadAsc, .releaseDateAsc, .folderNameAsc,
      .booksCountAsc:
      return .ascending
    case .nameDesc, .dateAddedDesc, .dateUpdatedDesc, .dateReadDesc, .releaseDateDesc,
      .folderNameDesc, .booksCountDesc:
      return .descending
    case .random: return .ascending  // Not used for random
    }
  }
}
