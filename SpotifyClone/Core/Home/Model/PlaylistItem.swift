//
//  PlaylistItem.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/8/3.
//

import Foundation

struct PlaylistItem: Identifiable, Codable {
    var id = UUID().uuidString
    let imageName: String
    let imageURL: URL?
    let title: String
    let artists: [String]?
    let description: String?
    let durationSum: String

    // 現有 init — 本地圖片，向下相容
    init(id: String = UUID().uuidString, imageName: String, title: String,
         artists: [String]? = nil, description: String? = nil, durationSum: String) {
        self.id = id
        self.imageName = imageName
        self.imageURL = nil
        self.title = title
        self.artists = artists
        self.description = description
        self.durationSum = durationSum
    }

    // 新增 init — 遠端 URL 圖片
    init(id: String = UUID().uuidString, imageURL: URL?, title: String,
         artists: [String]? = nil, description: String? = nil, durationSum: String) {
        self.id = id
        self.imageName = ""
        self.imageURL = imageURL
        self.title = title
        self.artists = artists
        self.description = description
        self.durationSum = durationSum
    }
}
