//
//  SeriesSearch.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation

// Simplified search structure that can encode to the correct JSON format for series list API
struct SeriesSearch: Encodable {
  let condition: [String: Any]?
  let fullTextSearch: String?

  init(condition: [String: Any]? = nil, fullTextSearch: String? = nil) {
    self.condition = condition
    self.fullTextSearch = fullTextSearch
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    if let condition = condition {
      // Use JSONSerialization to encode the condition dictionary
      let conditionJSON = try JSONSerialization.data(withJSONObject: condition)
      // Decode it back to a proper Codable structure
      let conditionDict = try JSONDecoder().decode([String: JSONAny].self, from: conditionJSON)
      try container.encodeIfPresent(conditionDict, forKey: .condition)
    }

    try container.encodeIfPresent(fullTextSearch, forKey: .fullTextSearch)
  }

  private enum CodingKeys: String, CodingKey {
    case condition
    case fullTextSearch
  }
}

// Helper functions to build conditions
extension SeriesSearch {
  static func buildCondition(
    libraryIds: [String]? = nil,
    readStatus: ReadStatus? = nil,
    seriesStatus: String? = nil,
    collectionId: String? = nil
  ) -> [String: Any]? {
    var conditions: [[String: Any]] = []

    // Support multiple libraryIds using anyOf
    if let libraryIds = libraryIds, !libraryIds.isEmpty {
      if libraryIds.count == 1 {
        // Single libraryId - use simple condition
        conditions.append([
          "libraryId": ["operator": "is", "value": libraryIds[0]]
        ])
      } else {
        // Multiple libraryIds - use anyOf to combine
        let libraryConditions = libraryIds.map { id in
          ["libraryId": ["operator": "is", "value": id]]
        }
        conditions.append(["anyOf": libraryConditions])
      }
    }

    if let readStatus = readStatus {
      // For series, readStatus needs to be wrapped in anyOf
      conditions.append([
        "anyOf": [
          [
            "readStatus": ["operator": "is", "value": readStatus.rawValue]
          ]
        ]
      ])
    }

    if let seriesStatus = seriesStatus {
      // Series status also needs to be wrapped in anyOf
      conditions.append([
        "anyOf": [
          [
            "seriesStatus": ["operator": "is", "value": seriesStatus]
          ]
        ]
      ])
    }

    if let collectionId = collectionId {
      conditions.append([
        "collectionId": ["operator": "is", "value": collectionId]
      ])
    }

    if conditions.isEmpty {
      return nil
    } else if conditions.count == 1 {
      return conditions[0]
    } else {
      return ["allOf": conditions]
    }
  }
}

// Extension to convert ReadStatusFilter to ReadStatus
extension ReadStatusFilter {
  func toReadStatus() -> ReadStatus? {
    switch self {
    case .all:
      return nil
    case .read:
      return .read
    case .unread:
      return .unread
    case .inProgress:
      return .inProgress
    }
  }
}
