//
//  APIError.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation

enum APIError: Error {
  case invalidURL
  case invalidResponse
  case httpError(Int, String)
  case decodingError(Error)
  case unauthorized
  case networkError(Error)
}
