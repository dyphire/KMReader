//
//  InfoChip.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct InfoChip: View {
  let label: String
  let systemImage: String?
  let backgroundColor: Color
  let foregroundColor: Color

  init(
    label: String,
    systemImage: String? = nil,
    backgroundColor: Color = Color.secondary.opacity(0.2),
    foregroundColor: Color = .primary
  ) {
    self.label = label
    self.systemImage = systemImage
    self.backgroundColor = backgroundColor
    self.foregroundColor = foregroundColor
  }

  var body: some View {
    HStack(spacing: 4) {
      if let systemImage = systemImage {
        Image(systemName: systemImage)
          .font(.caption2)
      }
      Text(label)
        .font(.caption)
    }
    .foregroundColor(foregroundColor)
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(backgroundColor)
    .cornerRadius(16)
  }
}
