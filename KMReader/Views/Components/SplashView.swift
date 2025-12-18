//
//  SplashView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct SplashView: View {
  @AppStorage("themeColorHex") private var themeColor: ThemeColor = .orange
  @State private var isVisible = false
  @State private var loadingMessageIndex = 0
  @State private var pulseProgress = 1.0

  private let loadingMessages = [
    "Connecting to server...",
    "Syncing your library...",
    "Updating your profile...",
    "Preparing your collection...",
  ]

  var body: some View {
    VStack(spacing: 32) {
      Spacer()

      VStack(spacing: 16) {
        // Logo with animation
        Image("logo")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: 140)
          .scaleEffect(isVisible ? 1.0 : 0.8)
          .opacity(isVisible ? 1.0 : 0.0)

        // App Name
        Text("KMReader")
          .font(.system(size: 48, weight: .bold, design: .rounded))
          .foregroundStyle(.primary)
          .tracking(1.2)
          .offset(y: isVisible ? 0 : 20)
          .opacity(isVisible ? 1.0 : 0.0)

        // Tagline
        Text("Your personal manga reader")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .tracking(0.5)
          .offset(y: isVisible ? 0 : 20)
          .opacity(isVisible ? 0.8 : 0.0)
      }

      Spacer()

      VStack(spacing: 16) {
        ProgressView()
          .controlSize(.large)
          .tint(themeColor.color)
          .scaleEffect(pulseProgress)
          .opacity(isVisible ? 1.0 : 0.0)

        Text(loadingMessages[loadingMessageIndex])
          .font(.caption)
          .foregroundStyle(.secondary)
          .monospacedDigit()
          .transition(
            .asymmetric(
              insertion: .move(edge: .bottom).combined(with: .opacity),
              removal: .move(edge: .top).combined(with: .opacity))
          )
          .id(loadingMessageIndex)
      }

      Spacer()
        .frame(height: 60)
    }
    .onAppear {
      withAnimation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0)) {
        isVisible = true
      }

      // Pulse animation for ProgressView
      withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
        pulseProgress = 1.1
      }

      // Rotate loading messages
      Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
        withAnimation(.easeInOut(duration: 0.5)) {
          loadingMessageIndex = (loadingMessageIndex + 1) % loadingMessages.count
        }
      }
    }
  }
}

#Preview {
  SplashView()
}
