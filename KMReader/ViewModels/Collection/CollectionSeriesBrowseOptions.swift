//
//  CollectionSeriesBrowseOptions.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation
import SwiftUI

struct CollectionSeriesBrowseOptions: Equatable, RawRepresentable {
  typealias RawValue = String

  var readStatusFilter: ReadStatusFilter = .all
  var seriesStatusFilter: SeriesStatusFilter = .all

  var rawValue: String {
    let dict: [String: String] = [
      "readStatusFilter": readStatusFilter.rawValue,
      "seriesStatusFilter": seriesStatusFilter.rawValue,
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
    self.readStatusFilter = ReadStatusFilter(rawValue: dict["readStatusFilter"] ?? "") ?? .all
    self.seriesStatusFilter = SeriesStatusFilter(rawValue: dict["seriesStatusFilter"] ?? "") ?? .all
  }

  init() {}
}
