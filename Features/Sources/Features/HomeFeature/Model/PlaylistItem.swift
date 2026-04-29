//
//  PlaylistItem.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/8/3.
//

import Foundation

struct PlaylistItem: Codable, Identifiable, Equatable {
    var id: String?
    let title: String?
    let imageURL: URL?
    let artists: [String]?
    let description: String?
    let durationSum: String?

    init(id: String?,
         title: String?,
         imageURL: URL?,
         artists: [String]? = nil,
         description: String? = nil,
         durationSum: String? = nil)
    {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.artists = artists
        self.description = description
        self.durationSum = durationSum
    }
}
