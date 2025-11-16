//
//  ContentView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct SettingsView: View {
  @Environment(AuthViewModel.self) private var authViewModel
  @AppStorage("webtoonPageWidthPercentage") private var webtoonPageWidthPercentage: Double = 100.0
  @AppStorage("themeColorName") private var themeColor: ThemeColorOption = .orange
  @AppStorage("maxDiskCacheSizeMB") private var maxDiskCacheSizeMB: Int = 2048
  @State private var showClearCacheConfirmation = false
  @State private var diskCacheSize: Int64 = 0
  @State private var diskCacheCount: Int = 0
  @State private var isLoadingCacheSize = false

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("Account")) {
          if let user = authViewModel.user {
            HStack {
              Text("Email")
              Spacer()
              Text(user.email)
                .foregroundColor(.secondary)
            }
            HStack {
              Text("Roles")
              Spacer()
              Text(user.roles.joined(separator: ", "))
                .font(.caption)
                .lineLimit(1)
                .foregroundColor(.secondary)
            }
          }
        }

        Section(header: Text("Appearance")) {
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Text("Theme Color")
              Spacer()
              Text(themeColor.displayName)
                .foregroundColor(.secondary)
            }

            LazyVGrid(
              columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12
            ) {
              ForEach(ThemeColorOption.allCases, id: \.self) { option in
                Button {
                  themeColor = option
                } label: {
                  Circle()
                    .fill(option.color)
                    .frame(width: 40, height: 40)
                    .overlay(
                      Circle()
                        .stroke(
                          themeColor == option
                            ? Color.primary : Color.primary.opacity(0.2),
                          lineWidth: themeColor == option ? 3 : 1
                        )
                    )
                    .overlay(
                      Group {
                        if themeColor == option {
                          Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 1)
                        }
                      }
                    )
                }
                .buttonStyle(.plain)
              }
            }
            .padding(.vertical, 4)
          }
        }

        Section(header: Text("Reader")) {
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text("Webtoon Page Width")
              Spacer()
              Text("\(Int(webtoonPageWidthPercentage))%")
                .foregroundColor(.secondary)
            }
            Slider(
              value: $webtoonPageWidthPercentage,
              in: 50...100,
              step: 5
            )
            Text("Adjust the width of webtoon pages as a percentage of screen width")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }

        Section(header: Text("Cache")) {
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text("Max Cache Size")
              Spacer()
              Text("\(maxDiskCacheSizeMB) MB")
                .foregroundColor(.secondary)
            }
            Slider(
              value: Binding(
                get: { Double(maxDiskCacheSizeMB) },
                set: { maxDiskCacheSizeMB = Int($0) }
              ),
              in: 512...8192,
              step: 256
            )
            Text(
              "Adjust the maximum disk cache size. Cache will be cleaned automatically when exceeded."
            )
            .font(.caption)
            .foregroundColor(.secondary)
          }

          HStack {
            Text("Disk Cache Size")
            Spacer()
            if isLoadingCacheSize {
              ProgressView()
                .scaleEffect(0.8)
            } else {
              Text(formatCacheSize(diskCacheSize))
                .foregroundColor(.secondary)
            }
          }

          HStack {
            Text("Cached Images")
            Spacer()
            if isLoadingCacheSize {
              ProgressView()
                .scaleEffect(0.8)
            } else {
              Text(formatCacheCount(diskCacheCount))
                .foregroundColor(.secondary)
            }
          }

          Button(role: .destructive) {
            showClearCacheConfirmation = true
          } label: {
            HStack {
              Spacer()
              Text("Clear Disk Cache")
              Spacer()
            }
          }
        }

        Section {
          Button(role: .destructive) {
            authViewModel.logout()
          } label: {
            HStack {
              Spacer()
              Text("Logout")
              Spacer()
            }
          }
        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .alert("Clear Disk Cache", isPresented: $showClearCacheConfirmation) {
        Button("Clear Cache", role: .destructive) {
          Task {
            await ImageCache.clearAllDiskCache()
            await loadCacheSize()
          }
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text(
          "This will remove all cached images from disk. Images will be re-downloaded when needed.")
      }
      .task {
        await loadCacheSize()
      }
      .onChange(of: maxDiskCacheSizeMB) { oldValue, newValue in
        // Trigger cache cleanup when max cache size changes
        Task {
          await ImageCache.cleanupDiskCacheIfNeeded()
          await loadCacheSize()
        }
      }
    }
  }

  private func loadCacheSize() async {
    isLoadingCacheSize = true
    async let size = ImageCache.getDiskCacheSize()
    async let count = ImageCache.getDiskCacheCount()
    diskCacheSize = await size
    diskCacheCount = await count
    isLoadingCacheSize = false
  }

  private func formatCacheSize(_ bytes: Int64) -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useMB, .useGB]
    formatter.countStyle = .file
    return formatter.string(fromByteCount: bytes)
  }

  private func formatCacheCount(_ count: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = ","
    return formatter.string(from: NSNumber(value: count)) ?? "\(count)"
  }
}
