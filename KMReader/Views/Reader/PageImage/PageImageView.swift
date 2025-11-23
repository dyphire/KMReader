//
//  PageImageView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Photos
import SDWebImage
import SDWebImageSwiftUI
import SwiftUI

// Pure image display component without zoom/pan logic
struct PageImageView: View {
  var viewModel: ReaderViewModel
  let pageIndex: Int

  @State private var imageURL: URL?
  @State private var loadError: String?

  private var currentPage: BookPage? {
    guard pageIndex >= 0 && pageIndex < viewModel.pages.count else {
      return nil
    }
    return viewModel.pages[pageIndex]
  }

  var body: some View {
    Group {
      if let imageURL = imageURL {
        WebImage(
          url: imageURL,
          options: [.retryFailed, .scaleDownLargeImages],
          context: [
            // Limit single image memory to 50MB (will scale down if larger)
            .imageScaleDownLimitBytes: 50 * 1024 * 1024,
            .customManager: SDImageCacheProvider.pageImageManager,
            .storeCacheType: SDImageCacheType.memory.rawValue,
            .queryCacheType: SDImageCacheType.memory.rawValue,
          ]
        )
        .resizable()
        .aspectRatio(contentMode: .fit)
        .transition(.fade)
      } else if let error = loadError {
        VStack(spacing: 16) {
          Image(systemName: "exclamationmark.triangle")
            .font(.system(size: 48))
            .foregroundColor(.white.opacity(0.7))
          Text("Failed to load image")
            .font(.headline)
            .foregroundColor(.white)
          Text(error)
            .font(.caption)
            .foregroundColor(.white.opacity(0.7))
            .multilineTextAlignment(.center)
            .padding(.horizontal)
          Button("Retry") {
            Task {
              loadError = nil
              if let page = currentPage {
                imageURL = await viewModel.getPageImageFileURL(page: page)
              } else {
                imageURL = nil
              }
              if imageURL == nil {
                loadError = "Please check your network connection"
              }
            }
          }
          .buttonStyle(.borderedProminent)
          .padding(.top, 8)
        }
      } else {
        ProgressView()
          .padding()
      }
    }
    .task(id: pageIndex) {
      // Clear previous URL and error
      imageURL = nil
      loadError = nil

      // Download to cache if needed, then get file URL
      // SDWebImage will handle decoding and display
      if let page = currentPage {
        imageURL = await viewModel.getPageImageFileURL(page: page)
      } else {
        imageURL = nil
        loadError = "Invalid page index."
      }

      // If download failed, show error
      if imageURL == nil && loadError == nil {
        loadError = "Failed to load page image. Please check your network connection."
      }
    }
    .onDisappear {
      // Clear URL when view disappears
      imageURL = nil
    }
  }
}
