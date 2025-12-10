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
    includeReadStatuses: [ReadStatus] = [],
    excludeReadStatuses: [ReadStatus] = [],
    includeSeriesStatuses: [String] = [],
    excludeSeriesStatuses: [String] = [],
    seriesStatusLogic: StatusFilterLogic = .all,
    includeOneshot: Bool? = nil,
    excludeOneshot: Bool? = nil,
    includeDeleted: Bool? = nil,
    excludeDeleted: Bool? = nil,
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

    if !includeReadStatuses.isEmpty {
      let statusConditions = includeReadStatuses.map {
        ["readStatus": ["operator": "is", "value": $0.rawValue]]
      }
      conditions.append(["anyOf": statusConditions])
    }

    if !excludeReadStatuses.isEmpty {
      let statusConditions = excludeReadStatuses.map {
        ["readStatus": ["operator": "isnot", "value": $0.rawValue]]
      }
      conditions.append(["allOf": statusConditions])
    }

    if !includeSeriesStatuses.isEmpty {
      let statusConditions = includeSeriesStatuses.map { status in
        ["seriesStatus": ["operator": "is", "value": status]]
      }
      let wrapperKey = seriesStatusLogic == .all ? "allOf" : "anyOf"
      conditions.append([wrapperKey: statusConditions])
    }

    if !excludeSeriesStatuses.isEmpty {
      let statusConditions = excludeSeriesStatuses.map { status in
        ["seriesStatus": ["operator": "isnot", "value": status]]
      }
      let wrapperKey = seriesStatusLogic == .all ? "allOf" : "anyOf"
      conditions.append([wrapperKey: statusConditions])
    }

    if let includeOneshot {
      conditions.append([
        "oneshot": [
          "operator": includeOneshot ? "istrue" : "isfalse"
        ]
      ])
    }

    if let excludeOneshot {
      conditions.append([
        "oneshot": [
          "operator": excludeOneshot ? "isfalse" : "istrue"
        ]
      ])
    }

    if let includeDeleted {
      conditions.append([
        "deleted": [
          "operator": includeDeleted ? "istrue" : "isfalse"
        ]
      ])
    }

    if let excludeDeleted {
      conditions.append([
        "deleted": [
          "operator": excludeDeleted ? "isfalse" : "istrue"
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
