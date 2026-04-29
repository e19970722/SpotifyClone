//
//  SpotifyRecentlyPlayedResponse.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/4/18.
//

import Foundation

struct SpotifyRecentlyPlayedResponse: Decodable {
    let href: String?
    let limit: Int?
    let next: String?
    let cursors: SpotifyRecentlyCursors?
    let items: [SpotifyRecentlyPlayedItem]?
}

struct SpotifyRecentlyCursors: Decodable {
    let after: String?
    let before: String?
}

struct SpotifyRecentlyPlayedItem: Decodable, Identifiable, Equatable {
    var id: String { playedAt ?? UUID().uuidString }
    let track: SpotifyRecentlyPlayedTrack?
    let playedAt: String?

    enum CodingKeys: String, CodingKey {
        case track
        case playedAt = "played_at"
    }
}

struct SpotifyRecentlyPlayedTrack: Decodable, Equatable {
    let id: String?
    let name: String?
    let artists: [SpotifyArtistItem]?
    let album: SpotifyRecentlyPlayedTrackAlbum?
}

struct SpotifyRecentlyPlayedTrackAlbum: Decodable, Equatable {
    let id: String?
    let name: String?
    let images: [SpotifyImage]?
}
