//
//  WebResourceCache.swift
//  KMReader
//
//  Created by Komga iOS Client
//

import Foundation

actor WebResourceCache {
  static let shared = WebResourceCache()

  private let fileManager = FileManager.default
  private let rootDirectory: URL
  private var downloadTasks: [String: Task<URL, Error>] = [:]

  init() {
    let cachesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    rootDirectory = cachesDir.appendingPathComponent("KomgaEpubCache", isDirectory: true)
    try? fileManager.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
  }

  func bookRootURL(bookId: String) -> URL {
    let url = rootDirectory.appendingPathComponent(bookId, isDirectory: true)
    if !fileManager.fileExists(atPath: url.path) {
      try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    }
    return url
  }

  func clear(bookId: String) {
    let url = rootDirectory.appendingPathComponent(bookId, isDirectory: true)
    try? fileManager.removeItem(at: url)
  }

  // MARK: - EPUB File Cache

  func cachedEpubFileURL(bookId: String) -> URL? {
    let fileURL = epubFileURL(bookId: bookId)
    if fileManager.fileExists(atPath: fileURL.path) {
      return fileURL
    }
    return nil
  }

  func ensureEpubFile(
    bookId: String,
    downloader: @escaping () async throws -> Data
  ) async throws -> URL {
    if let existing = cachedEpubFileURL(bookId: bookId) {
      return existing
    }

    let cacheKey = "epub#\(bookId)"
    if let task = downloadTasks[cacheKey] {
      return try await task.value
    }

    let task = Task<URL, Error> {
      let data = try await downloader()
      let destination = epubFileURL(bookId: bookId)
      let directory = destination.deletingLastPathComponent()
      if !fileManager.fileExists(atPath: directory.path) {
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
      }
      try data.write(to: destination, options: [.atomic])
      return destination
    }
    downloadTasks[cacheKey] = task

    do {
      let value = try await task.value
      downloadTasks[cacheKey] = nil
      return value
    } catch {
      downloadTasks[cacheKey] = nil
      throw error
    }
  }

  private func epubFileURL(bookId: String) -> URL {
    let base = bookRootURL(bookId: bookId)
    return base.appendingPathComponent("book.epub", isDirectory: false)
  }
}
