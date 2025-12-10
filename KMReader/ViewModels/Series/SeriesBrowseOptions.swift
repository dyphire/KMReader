//
//  SeriesBrowseOptions.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation
import SwiftUI

struct SeriesBrowseOptions: Equatable, RawRepresentable {
  typealias RawValue = String

  var includeReadStatuses: Set<ReadStatusFilter> = []
  var excludeReadStatuses: Set<ReadStatusFilter> = []
  var includeSeriesStatuses: Set<SeriesStatusFilter> = []
  var excludeSeriesStatuses: Set<SeriesStatusFilter> = []
  var seriesStatusLogic: StatusFilterLogic = .all
  var oneshotFilter: TriStateFilter<BoolTriStateFlag> = TriStateFilter()
  var deletedFilter: TriStateFilter<BoolTriStateFlag> = TriStateFilter()
  var sortField: SeriesSortField = .name
  var sortDirection: SortDirection = .ascending

  var sortString: String {
    if sortField == .random {
      return "random"
    }
    return "\(sortField.rawValue),\(sortDirection.rawValue)"
  }

  var rawValue: String {
    let dict: [String: String] = [
      "includeReadStatuses": includeReadStatuses.map { $0.rawValue }.joined(separator: ","),
      "excludeReadStatuses": excludeReadStatuses.map { $0.rawValue }.joined(separator: ","),
      "includeSeriesStatuses": includeSeriesStatuses.map { $0.rawValue }.joined(separator: ","),
      "excludeSeriesStatuses": excludeSeriesStatuses.map { $0.rawValue }.joined(separator: ","),
      "seriesStatusLogic": seriesStatusLogic.rawValue,
      "oneshotFilter": oneshotFilter.storageValue,
      "deletedFilter": deletedFilter.storageValue,
      "sortField": sortField.rawValue,
      "sortDirection": sortDirection.rawValue,
    ]
    if let data = try? JSONSerialization.data(withJSONObject: dict),
      let json = String(data: data, encoding: .utf8)
    {
      return json
    }
    return "{}"
  }

  init?(rawValue: String) {
    guard !rawValue.isEmpty else {
      return nil
    }
    guard let data = rawValue.data(using: .utf8),
      let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String]
    else {
      return nil
    }
    let includeReadRaw = dict["includeReadStatuses"] ?? ""
    let excludeReadRaw = dict["excludeReadStatuses"] ?? ""
    self.includeReadStatuses = Set(
      includeReadRaw.split(separator: ",").compactMap { ReadStatusFilter(rawValue: String($0)) })
    self.excludeReadStatuses = Set(
      excludeReadRaw.split(separator: ",").compactMap { ReadStatusFilter(rawValue: String($0)) })

    if includeReadStatuses.isEmpty && excludeReadStatuses.isEmpty,
      let legacy = dict["readStatusFilter"]
    {
      let tri = TriStateFilter<ReadStatusFilter>.decode(legacy, offValues: [.all])
      if let value = tri.value {
        if tri.state == .exclude {
          excludeReadStatuses.insert(value)
        } else if tri.state == .include {
          includeReadStatuses.insert(value)
        }
      }
    }

    let includeRaw = dict["includeSeriesStatuses"] ?? ""
    let excludeRaw = dict["excludeSeriesStatuses"] ?? ""
    self.includeSeriesStatuses = Set(
      includeRaw.split(separator: ",").compactMap { SeriesStatusFilter.decodeCompat(String($0)) })
    self.excludeSeriesStatuses = Set(
      excludeRaw.split(separator: ",").compactMap { SeriesStatusFilter.decodeCompat(String($0)) })

    // Backward compatibility for legacy single-value tri-state
    if includeSeriesStatuses.isEmpty && excludeSeriesStatuses.isEmpty,
      let legacy = dict["seriesStatusFilter"]
    {
      let tri = TriStateFilter<SeriesStatusFilter>.decode(legacy, offValues: [.all])
      if let value = tri.value {
        if tri.state == .exclude {
          excludeSeriesStatuses.insert(value)
        } else if tri.state == .include {
          includeSeriesStatuses.insert(value)
        }
      }
    }

    let logicRaw = dict["seriesStatusLogic"] ?? ""
    self.seriesStatusLogic =
      StatusFilterLogic(rawValue: logicRaw)
      ?? (logicRaw == "AND" ? .all : logicRaw == "OR" ? .any : .all)
    self.oneshotFilter = TriStateFilter.decode(dict["oneshotFilter"])
    self.deletedFilter = TriStateFilter.decode(dict["deletedFilter"])
    self.sortField = SeriesSortField(rawValue: dict["sortField"] ?? "") ?? .name
    self.sortDirection = SortDirection(rawValue: dict["sortDirection"] ?? "") ?? .ascending
  }

  init() {}
}
