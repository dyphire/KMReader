//
//  RequestModifierHelper.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation

enum RequestModifierHelper {
  /// Modify a URLRequest to add domain-specific headers
  /// Currently adds skip_zrok_interstitial header for zrok.io domains
  static func modify(_ request: URLRequest) -> URLRequest {
    if let url = request.url,
      let host = url.host,
      host.contains("zrok.io")
    {
      var modifiedRequest = request
      modifiedRequest.setValue("1", forHTTPHeaderField: "skip_zrok_interstitial")
      return modifiedRequest
    }

    return request
  }

  /// Modify a URLRequest in-place to add domain-specific headers
  /// Currently adds skip_zrok_interstitial header for zrok.io domains
  static func modifyInPlace(_ request: inout URLRequest) {
    if let url = request.url,
      let host = url.host,
      host.contains("zrok.io")
    {
      request.setValue("1", forHTTPHeaderField: "skip_zrok_interstitial")
    }
  }
}
