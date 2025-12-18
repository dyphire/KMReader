//
//  KomgaInstance.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation
import SwiftData

@Model
final class KomgaInstance {
  @Attribute(.unique) var id: UUID
  var name: String
  var serverURL: String
  var username: String
  var authToken: String
  var isAdmin: Bool
  var authMethod: AuthenticationMethod? = AuthenticationMethod.basicAuth
  var createdAt: Date
  var lastUsedAt: Date

  init(
    id: UUID = UUID(),
    name: String,
    serverURL: String,
    username: String,
    authToken: String,
    isAdmin: Bool,
    authMethod: AuthenticationMethod = .basicAuth,
    createdAt: Date = Date(),
    lastUsedAt: Date = Date()
  ) {
    self.id = id
    self.name = name
    self.serverURL = serverURL
    self.username = username
    self.authToken = authToken
    self.isAdmin = isAdmin
    self.authMethod = authMethod
    self.createdAt = createdAt
    self.lastUsedAt = lastUsedAt
  }

  var displayName: String {
    name.isEmpty ? serverURL : name
  }

  var resolvedAuthMethod: AuthenticationMethod {
    authMethod ?? .basicAuth
  }
}
