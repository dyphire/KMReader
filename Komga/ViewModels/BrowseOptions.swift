//
//  BrowseOptions.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation
import SwiftUI

@MainActor
@Observable
class BrowseOptions: Equatable {
  var libraryId: String = ""
  var readStatusFilter: ReadStatusFilter = .all
  var seriesStatusFilter: SeriesStatusFilter = .all
  var sortField: SeriesSortField = .name
  var sortDirection: SortDirection = .ascending

  // Computed property to generate sort string for API
  var sortString: String {
    if sortField == .random {
      return "random"
    }
    return "\(sortField.rawValue),\(sortDirection.rawValue)"
  }

  static func == (lhs: BrowseOptions, rhs: BrowseOptions) -> Bool {
    return lhs.libraryId == rhs.libraryId
      && lhs.readStatusFilter == rhs.readStatusFilter
      && lhs.seriesStatusFilter == rhs.seriesStatusFilter
      && lhs.sortField == rhs.sortField
      && lhs.sortDirection == rhs.sortDirection
  }
}
