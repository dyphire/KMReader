//
//  SettingsView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct SettingsView: View {
  @Environment(AuthViewModel.self) private var authViewModel

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

        Section {
          NavigationLink(value: NavDestination.settingsLibraries) {
            Text("Library Management")
          }
        }

        Section {
          NavigationLink(value: NavDestination.settingsAppearance) {
            Text("Appearance")
          }
          NavigationLink(value: NavDestination.settingsCache) {
            Text("Cache")
          }
          NavigationLink(value: NavDestination.settingsReader) {
            Text("Reader")
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
      .handleNavigation()
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}
