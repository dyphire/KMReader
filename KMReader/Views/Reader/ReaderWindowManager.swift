//
//  ReaderWindowManager.swift
//  Komga
//
//  Created by Komga iOS Client
//

#if canImport(AppKit)
  import SwiftUI

  // Manager to pass reader state to window
  @MainActor
  @Observable
  class ReaderWindowManager {
    static let shared = ReaderWindowManager()
    var currentState: BookReaderState?

    private init() {}

    func openReader(book: Book, incognito: Bool = false) {
      currentState = BookReaderState(book: book, incognito: incognito)
    }

    func closeReader() {
      currentState = nil
    }
  }
#endif
