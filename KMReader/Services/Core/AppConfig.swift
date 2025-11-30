//
//  AppConfig.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation

/// Centralized configuration management using UserDefaults
enum AppConfig {
  private static let defaults = UserDefaults.standard

  // MARK: - Server & Auth
  static var serverURL: String {
    get { defaults.string(forKey: "serverURL") ?? "" }
    set { defaults.set(newValue, forKey: "serverURL") }
  }

  static var serverDisplayName: String {
    get { defaults.string(forKey: "serverDisplayName") ?? "" }
    set { defaults.set(newValue, forKey: "serverDisplayName") }
  }

  static var authToken: String {
    get { defaults.string(forKey: "authToken") ?? "" }
    set { defaults.set(newValue, forKey: "authToken") }
  }

  static var username: String {
    get { defaults.string(forKey: "username") ?? "" }
    set { defaults.set(newValue, forKey: "username") }
  }

  static var isLoggedIn: Bool {
    get { defaults.bool(forKey: "isLoggedIn") }
    set { defaults.set(newValue, forKey: "isLoggedIn") }
  }

  static var isAdmin: Bool {
    get { defaults.bool(forKey: "isAdmin") }
    set { defaults.set(newValue, forKey: "isAdmin") }
  }

  static var selectedLibraryId: String {
    get { defaults.string(forKey: "selectedLibraryId") ?? "" }
    set { defaults.set(newValue, forKey: "selectedLibraryId") }
  }

  static var deviceIdentifier: String? {
    get { defaults.string(forKey: "deviceIdentifier") }
    set {
      if let value = newValue {
        defaults.set(value, forKey: "deviceIdentifier")
      } else {
        defaults.removeObject(forKey: "deviceIdentifier")
      }
    }
  }

  static var dualPageNoCover: Bool {
    get { defaults.bool(forKey: "dualPageNoCover") }
    set { defaults.set(newValue, forKey: "dualPageNoCover") }
  }

  static var currentInstanceId: String {
    get { defaults.string(forKey: "currentInstanceId") ?? "" }
    set { defaults.set(newValue, forKey: "currentInstanceId") }
  }

  static var maxDiskCacheSizeMB: Int {
    get {
      if defaults.object(forKey: "maxDiskCacheSizeMB") != nil {
        return defaults.integer(forKey: "maxDiskCacheSizeMB")
      }
      return 2048
    }
    set { defaults.set(newValue, forKey: "maxDiskCacheSizeMB") }
  }

  // MARK: - Custom Fonts
  static var customFontNames: [String] {
    get {
      defaults.stringArray(forKey: "customFontNames") ?? []
    }
    set {
      defaults.set(newValue, forKey: "customFontNames")
    }
  }

  // MARK: - Dashboard Sections
  // Array of visible sections in display order. Sections not in array are hidden.
  static var dashboardSections: [DashboardSection] {
    get {
      guard let data = defaults.data(forKey: "dashboardSections"),
        let sections = try? JSONDecoder().decode([DashboardSection].self, from: data)
      else {
        // Return default order with all sections visible
        return DashboardSection.allCases
      }
      return sections
    }
    set {
      if let data = try? JSONEncoder().encode(newValue) {
        defaults.set(data, forKey: "dashboardSections")
      }
    }
  }

  // MARK: - Clear all auth data
  static func clearAuthData() {
    authToken = ""
    username = ""
    serverDisplayName = ""
    isAdmin = false
    selectedLibraryId = ""
    currentInstanceId = ""
  }
}
