//
//  WebtoonLayout.swift
//  Komga
//
//  Created by Komga iOS Client
//

import Foundation
import UIKit

class WebtoonLayout: UICollectionViewFlowLayout {
  override func prepare() {
    super.prepare()
    scrollDirection = .vertical
    minimumLineSpacing = 0
    minimumInteritemSpacing = 0
    sectionInset = .zero
  }
}
