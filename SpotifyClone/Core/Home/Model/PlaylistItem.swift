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
    let title: String
    let artists: [String]?
    let description: String?
    let durationSum: String
    
    init(id: String = UUID().uuidString, imageName: String, title: String,
         artists: [String]? = nil, description: String? = nil, durationSum: String) {
        self.id = id
        self.imageName = imageName
        self.title = title
        self.artists = artists
        self.description = description
        self.durationSum = durationSum
    }
}
