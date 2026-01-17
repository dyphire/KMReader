//
//  SplitPageImageView.swift
//  KMReader
//
//  Displays a wide page split into left and right halves
//

import SwiftUI

// Split page image view: displays a single wide image split into two halves
struct SplitPageImageView: View {
  var viewModel: ReaderViewModel
  let pageIndex: Int
  let screenSize: CGSize
  @Binding var isZoomed: Bool

  let readingDirection: ReadingDirection
  let onNextPage: () -> Void
  let onPreviousPage: () -> Void
  let onToggleControls: () -> Void

  @AppStorage("doubleTapZoomScale") private var doubleTapZoomScale: Double = 2.0

  init(
    viewModel: ReaderViewModel,
    pageIndex: Int,
    screenSize: CGSize,
    readingDirection: ReadingDirection = .ltr,
    isZoomed: Binding<Bool> = .constant(false),
    onNextPage: @escaping () -> Void = {},
    onPreviousPage: @escaping () -> Void = {},
    onToggleControls: @escaping () -> Void = {}
  ) {
    self.viewModel = viewModel
    self.pageIndex = pageIndex
    self.screenSize = screenSize
    self.readingDirection = readingDirection
    self._isZoomed = isZoomed
    self.onNextPage = onNextPage
    self.onPreviousPage = onPreviousPage
    self.onToggleControls = onToggleControls
  }

  var body: some View {
    let page = pageIndex >= 0 && pageIndex < viewModel.pages.count ? viewModel.pages[pageIndex] : nil

    PageImageView(
      viewModel: viewModel,
      screenSize: screenSize,
      resetID: "\(pageIndex)-split",
      minScale: 1.0,
      maxScale: 8.0,
      doubleTapScale: doubleTapZoomScale,
      readingDirection: readingDirection,
      onNextPage: onNextPage,
      onPreviousPage: onPreviousPage,
      onToggleControls: onToggleControls,
      pages: [
        NativePageData(
          bookId: viewModel.bookId,
          pageNumber: pageIndex,
          isLoading: viewModel.isLoading && page != nil && viewModel.preloadedImages[pageIndex] == nil,
          error: nil,
          alignment: .trailing,  // Left half
          cropMode: .leftHalf
        ),
        NativePageData(
          bookId: viewModel.bookId,
          pageNumber: pageIndex,
          isLoading: viewModel.isLoading && page != nil && viewModel.preloadedImages[pageIndex] == nil,
          error: nil,
          alignment: .leading,  // Right half
          cropMode: .rightHalf
        ),
      ]
    )
  }
}
