//
//  KomgaLibraryStore.swift
//  KMReader
//
//  Created by Komga iOS Client
//

import Foundation
import SwiftData

@MainActor
final class KomgaLibraryStore {
  static let shared = KomgaLibraryStore()

  private var container: ModelContainer?

  private init() {}

  func configure(with container: ModelContainer) {
    self.container = container
  }

  private func makeContext() throws -> ModelContext {
    guard let container else {
      throw AppErrorType.storageNotConfigured(message: "ModelContainer is not configured")
    }
    return ModelContext(container)
  }

  func fetchLibraries(instanceId: String) -> [LibraryInfo] {
    guard let container else { return [] }
    let context = ModelContext(container)
    let descriptor = FetchDescriptor<KomgaLibrary>(
      predicate: #Predicate { $0.instanceId == instanceId },
      sortBy: [SortDescriptor(\KomgaLibrary.name, order: .forward)]
    )
    guard let libraries = try? context.fetch(descriptor) else { return [] }
    return libraries.map { LibraryInfo(id: $0.libraryId, name: $0.name) }
  }

  func replaceLibraries(_ libraries: [LibraryInfo], for instanceId: String) throws {
    let context = try makeContext()
    let descriptor = FetchDescriptor<KomgaLibrary>(
      predicate: #Predicate { $0.instanceId == instanceId }
    )
    let existing = try context.fetch(descriptor)

    // Create a map of existing libraries by libraryId for quick lookup
    var existingMap = Dictionary(
      uniqueKeysWithValues: existing.map { ($0.libraryId, $0) }
    )

    // Update existing libraries or insert new ones
    for library in libraries {
      if let existingLibrary = existingMap[library.id] {
        // Update existing library (preserves metrics)
        existingLibrary.name = library.name
        existingMap.removeValue(forKey: library.id)
      } else {
        // Insert new library
        context.insert(
          KomgaLibrary(
            instanceId: instanceId,
            libraryId: library.id,
            name: library.name
          ))
      }
    }

    // Delete libraries that no longer exist (but preserve __all_libraries__ entry)
    let allLibrariesId = KomgaLibrary.allLibrariesId
    for (_, library) in existingMap {
      if library.libraryId != allLibrariesId {
        context.delete(library)
      }
    }

    try context.save()
  }

  func deleteLibraries(instanceId: String?) throws {
    let context = try makeContext()
    let descriptor: FetchDescriptor<KomgaLibrary>
    if let instanceId {
      descriptor = FetchDescriptor(
        predicate: #Predicate { $0.instanceId == instanceId }
      )
    } else {
      descriptor = FetchDescriptor()
    }
    let items = try context.fetch(descriptor)
    items.forEach { context.delete($0) }
    try context.save()
  }

  func upsertAllLibrariesEntry(
    instanceId: String,
    fileSize: Double?,
    booksCount: Double?,
    seriesCount: Double?,
    sidecarsCount: Double?,
    collectionsCount: Double?,
    readlistsCount: Double?
  ) throws {
    let context = try makeContext()
    let allLibrariesId = KomgaLibrary.allLibrariesId
    let descriptor = FetchDescriptor<KomgaLibrary>(
      predicate: #Predicate { library in
        library.instanceId == instanceId && library.libraryId == allLibrariesId
      }
    )

    if let existing = try context.fetch(descriptor).first {
      existing.fileSize = fileSize
      existing.booksCount = booksCount
      existing.seriesCount = seriesCount
      existing.sidecarsCount = sidecarsCount
      existing.collectionsCount = collectionsCount
      existing.readlistsCount = readlistsCount
    } else {
      let allLibrariesEntry = KomgaLibrary(
        instanceId: instanceId,
        libraryId: KomgaLibrary.allLibrariesId,
        name: "All Libraries",
        fileSize: fileSize,
        booksCount: booksCount,
        seriesCount: seriesCount,
        sidecarsCount: sidecarsCount,
        collectionsCount: collectionsCount,
        readlistsCount: readlistsCount
      )
      context.insert(allLibrariesEntry)
    }

    try context.save()
  }
}
