//
//  BookReaderView.swift
//  KMReader
//
//  Created by Komga iOS Client
//

import SwiftUI

struct BookReaderView: View {
  let book: Book
  let incognito: Bool

  private var profile: MediaProfile {
    book.media.mediaProfile ?? .divina
  }

  var body: some View {
    switch profile {
    case .epub:
      EpubReaderView(bookId: book.id, incognito: incognito)
    case .divina, .pdf, .unknown:
      DivinaReaderView(bookId: book.id, incognito: incognito)
    }
  }
}
