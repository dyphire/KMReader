//
//  TapZoneOverlay.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

// Overlay for horizontal and vertical page views
struct PageTapZoneOverlay: View {
  let orientation: Orientation
  let isRTL: Bool
  @State private var isVisible = false

  enum Orientation {
    case horizontal
    case vertical
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        if orientation == .horizontal {
          // Horizontal layout: left and right zones
          HStack(spacing: 0) {
            // Left zone (35%)
            Rectangle()
              .fill((isRTL ? Color.green : Color.red).opacity(0.3))
              .frame(width: geometry.size.width * 0.35)

            Spacer()

            // Right zone (35%)
            Rectangle()
              .fill((isRTL ? Color.red : Color.green).opacity(0.3))
              .frame(width: geometry.size.width * 0.35)
          }
        } else {
          // Vertical layout: top (previous) and bottom (next)
          VStack(spacing: 0) {
            // Previous page zone (top 35%)
            Rectangle()
              .fill(Color.red.opacity(0.3))
              .frame(height: geometry.size.height * 0.35)

            Spacer()

            // Next page zone (bottom 35%)
            Rectangle()
              .fill(Color.green.opacity(0.3))
              .frame(height: geometry.size.height * 0.35)
          }
        }
      }
      .opacity(isVisible ? 1.0 : 0.0)
      .allowsHitTesting(false)
      .onAppear {
        // Show overlay immediately
        isVisible = true

        // Hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
          withAnimation(.easeOut(duration: 0.5)) {
            isVisible = false
          }
        }
      }
    }
  }
}

// Overlay for webtoon view - L-shaped tap zones
struct WebtoonTapZoneOverlay: View {
  @State private var isVisible = false

  // Match the thresholds from WebtoonReaderView.swift Constants
  private let topAreaThreshold: CGFloat = 0.35
  private let bottomAreaThreshold: CGFloat = 0.65
  private let centerAreaMin: CGFloat = 0.35
  private let centerAreaMax: CGFloat = 0.65

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .topLeading) {
        // Red area - Top full width
        Rectangle()
          .fill(Color.red.opacity(0.3))
          .frame(
            width: geometry.size.width,
            height: geometry.size.height * topAreaThreshold
          )
          .position(
            x: geometry.size.width / 2,
            y: geometry.size.height * topAreaThreshold / 2
          )

        // Red area - Left middle
        Rectangle()
          .fill(Color.red.opacity(0.3))
          .frame(
            width: geometry.size.width * topAreaThreshold,
            height: geometry.size.height * (centerAreaMax - centerAreaMin)
          )
          .position(
            x: geometry.size.width * topAreaThreshold / 2,
            y: geometry.size.height * (centerAreaMin + centerAreaMax) / 2
          )

        // Green area - Right middle
        Rectangle()
          .fill(Color.green.opacity(0.3))
          .frame(
            width: geometry.size.width * (1.0 - centerAreaMax),
            height: geometry.size.height * (centerAreaMax - centerAreaMin)
          )
          .position(
            x: geometry.size.width * (centerAreaMax + 1.0) / 2,
            y: geometry.size.height * (centerAreaMin + centerAreaMax) / 2
          )

        // Green area - Bottom full width
        Rectangle()
          .fill(Color.green.opacity(0.3))
          .frame(
            width: geometry.size.width,
            height: geometry.size.height * (1.0 - bottomAreaThreshold)
          )
          .position(
            x: geometry.size.width / 2,
            y: geometry.size.height * (bottomAreaThreshold + 1.0) / 2
          )

        // Center area border (transparent to show the center toggle area)
        Rectangle()
          .fill(Color.clear)
          .frame(
            width: geometry.size.width * (centerAreaMax - centerAreaMin),
            height: geometry.size.height * (centerAreaMax - centerAreaMin)
          )
          .position(
            x: geometry.size.width * (centerAreaMin + centerAreaMax) / 2,
            y: geometry.size.height * (centerAreaMin + centerAreaMax) / 2
          )
      }
      .opacity(isVisible ? 1.0 : 0.0)
      .allowsHitTesting(false)
      .onAppear {
        // Show overlay immediately
        isVisible = true

        // Hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
          withAnimation(.easeOut(duration: 0.5)) {
            isVisible = false
          }
        }
      }
    }
  }
}
