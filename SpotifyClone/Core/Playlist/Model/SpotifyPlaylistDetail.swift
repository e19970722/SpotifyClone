//
//  SpotifyPlaylistDetail.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/4/1.
//

import Foundation

struct SpotifyPlaylistDetail: Decodable {
    let id: String
    let name: String?
    let description: String?
    let images: [SpotifyImage]?
    let owner: SpotifyPlaylistOwner?
    let tracks: SpotifyPlaylistTracks?

    enum CodingKeys: String, CodingKey {
        case id, name, description, images, owner
        case tracks = "items"
    }

    func toAlbumItem() -> AlbumItem {
        let imageURL = images?.first.flatMap { URL(string: $0.url) }
        let ownerName = owner?.displayName
        let trackItems: [TrackItem]? = tracks?.items?.compactMap { wrapper -> TrackItem? in
            guard let track = wrapper.track else { return nil }
            let artists = track.artists?
                .compactMap { $0.name }
                .joined(separator: ", ")
            let trackImageURL = track.album?.images?.first.flatMap { URL(string: $0.url) }
            return TrackItem(
                id: track.id ?? UUID().uuidString,
                title: track.name ?? "",
                artists: artists,
                imageURL: trackImageURL,
                hasVideo: false
            )
        }

        return AlbumItem(
            title: name,
            imageURL: imageURL,
            artists: ownerName.map { [$0] },
            description: description,
            madeFor: ownerName,
            tracks: trackItems
        )
    }
}

struct SpotifyPlaylistOwner: Decodable {
    let displayName: String?

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
    }
}

struct SpotifyPlaylistTracks: Decodable {
    let items: [SpotifyPlaylistTrackWrapper]?
}

struct SpotifyPlaylistTrackWrapper: Decodable {
    let track: SpotifyTrack?

    enum CodingKeys: String, CodingKey {
        case track = "item"
    }
}

struct SpotifyTrack: Decodable {
    let id: String?
    let name: String?
    let artists: [SpotifyArtistItem]?
    let album: SpotifyTrackAlbum?
    let durationMs: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, artists, album
        case durationMs = "duration_ms"
    }
}

struct SpotifyArtistItem: Decodable {
    let name: String?
}

struct SpotifyTrackAlbum: Decodable {
    let images: [SpotifyImage]?
}
