//
//  UnreadIndicator.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct UnreadIndicator: View {
  @AppStorage("themeColorName") private var themeColorOption: ThemeColorOption = .orange

  var body: some View {
    ZStack {
      // Outer circle with background color
      Circle()
        .fill(Color(UIColor.systemBackground))
        .frame(width: 16, height: 16)

      // Inner circle with theme color
      Circle()
        .fill(themeColorOption.color)
        .frame(width: 8, height: 8)
    }
    .padding(-8)
  }
}
