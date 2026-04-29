//
//  SpotifyUserSavedAlbumsResponse.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/4/18.
//

import Foundation

struct SpotifyUserSavedAlbumsResponse: Decodable {
    let href: String?
    let limit: Int?
    let offset: Int?
    let total: Int?
    let next: String?
    let items: [SpotifyUserSavedAlbumWrapper]?
}

struct SpotifyUserSavedAlbumWrapper: Decodable {
    let addedAt: String?
    let album: SpotifyUserSavedAlbum?

    enum CodingKeys: String, CodingKey {
        case addedAt = "added_at"
        case album
    }
}

struct SpotifyUserSavedAlbum: Decodable, Identifiable {
    let id: String?
    let name: String?
    let albumType: String?
    let totalTracks: Int?
    let releaseDate: String?
    let images: [SpotifyImage]?
    let artists: [SpotifyArtistItem]?
    let externalUrls: SpotifyExternalUrls?

    enum CodingKeys: String, CodingKey {
        case id, name, images, artists
        case albumType    = "album_type"
        case totalTracks  = "total_tracks"
        case releaseDate  = "release_date"
        case externalUrls = "external_urls"
    }
}
