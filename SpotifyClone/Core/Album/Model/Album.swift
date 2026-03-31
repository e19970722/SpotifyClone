//
//  Album.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/30.
//

import Foundation

struct AlbumItem: Hashable {
    let title: String?
    let imageURL: URL?
    let artists: [String]?
    let description: String?
    let duration: String?
    let madeFor: String?
    let tags: [String]?
    let tracks: [TrackItem]?
    
    init(title: String?,
         imageURL: URL? = nil,
         artists: [String]? = nil,
         description: String? = nil,
         duration: String? = nil,
         madeFor: String? = nil,
         tags: [String]? = nil,
         tracks: [TrackItem]? = nil)
    {
        self.title = title
        self.imageURL = imageURL
        self.artists = artists
        self.description = description
        self.duration = duration
        self.madeFor = madeFor
        self.tags = tags
        self.tracks = tracks
    }
}

struct TrackItem: Identifiable, Hashable {
    let id: String
    let title: String
    let artists: String?
    let imageURL: URL?
    let hasVideo: Bool
}
