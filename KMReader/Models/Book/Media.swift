//
//  Media.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation

struct Media: Codable, Equatable {
  let status: String
  let mediaType: String
  let pagesCount: Int
  let comment: String?
  let mediaProfile: String?
  let epubDivinaCompatible: Bool?
  let epubIsKepub: Bool?
}
