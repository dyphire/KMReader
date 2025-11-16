//
//  ThumbnailImage.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SDWebImageSwiftUI
import SwiftUI

/// A reusable thumbnail image component using SDWebImageSwiftUI
struct ThumbnailImage: View {
  let url: URL?
  let contentMode: ContentMode
  let showPlaceholder: Bool

  init(
    url: URL?,
    contentMode: ContentMode = .fill,
    showPlaceholder: Bool = true
  ) {
    self.url = url
    self.contentMode = contentMode
    self.showPlaceholder = showPlaceholder
  }

  var body: some View {
    if let url = url {
      WebImage(url: url)
        .resizable()
        .placeholder {
          if showPlaceholder {
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .overlay {
                ProgressView()
              }
          } else {
            Rectangle()
              .fill(Color.gray.opacity(0.3))
          }
        }
        .indicator(.activity)
        .transition(.fade(duration: 0.2))
        .aspectRatio(contentMode: contentMode)
    } else {
      Rectangle()
        .fill(Color.gray.opacity(0.3))
        .overlay {
          if showPlaceholder {
            ProgressView()
          }
        }
    }
  }
}
