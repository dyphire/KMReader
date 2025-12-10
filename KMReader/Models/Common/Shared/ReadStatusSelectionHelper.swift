//
//  ReadStatusSelectionHelper.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation

func resolveReadStatusState(
  for status: ReadStatusFilter,
  include: Set<ReadStatusFilter>,
  exclude: Set<ReadStatusFilter>
) -> TriStateSelection {
  if include.contains(status) {
    return .include
  }
  if exclude.contains(status) {
    return .exclude
  }
  return .off
}

func applyReadStatusToggle(
  _ status: ReadStatusFilter,
  include: inout Set<ReadStatusFilter>,
  exclude: inout Set<ReadStatusFilter>
) {
  if include.contains(status) {
    include.remove(status)
    exclude.insert(status)
  } else if exclude.contains(status) {
    exclude.remove(status)
  } else {
    include.insert(status)
  }
}

func buildReadStatusLabel(include: Set<ReadStatusFilter>, exclude: Set<ReadStatusFilter>) -> String?
{
  let includeNames = include.map { $0.displayName }.sorted()
  let excludeNames = exclude.map { $0.displayName }.sorted()

  var parts: [String] = []
  if !includeNames.isEmpty {
    parts.append(includeNames.joined(separator: " ∨ "))
  }
  if !excludeNames.isEmpty {
    parts.append("≠ " + excludeNames.joined(separator: " ∨ "))
  }

  return parts.isEmpty ? nil : parts.joined(separator: ", ")
}
