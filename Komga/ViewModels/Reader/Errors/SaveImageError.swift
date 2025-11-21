//
//  SaveImageError.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation

enum SaveImageError: Error, LocalizedError {
  case bookIdEmpty
  case imageNotCached
  case photoLibraryAccessDenied
  case failedToLoadImageData
  case saveError(String)

  var errorDescription: String? {
    switch self {
    case .bookIdEmpty:
      return "Book ID is empty"
    case .imageNotCached:
      return "Image not cached yet"
    case .photoLibraryAccessDenied:
      return "Photo library access denied"
    case .failedToLoadImageData:
      return "Failed to load image data"
    case .saveError(let message):
      return message
    }
  }
}
