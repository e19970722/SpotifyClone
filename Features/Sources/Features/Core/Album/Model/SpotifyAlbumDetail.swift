//
//  SpotifyAlbumDetail.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/4/23.
//

import Foundation

struct SpotifyAlbumDetail: Decodable {
    let id: String?
    let name: String?
    let images: [SpotifyImage]?
    let artists: [SpotifyArtistItem]?
    let tracks: SpotifyAlbumTracks?

    func toAlbumItem() -> AlbumItem {
        let imageURL = images?.first.flatMap { $0.url.flatMap { URL(string: $0) } }
        let artistNames = artists?.compactMap { $0.name }
        let trackItems: [TrackItem]? = tracks?.items?.compactMap { track -> TrackItem? in
            guard let track else { return nil }
            let artists = track.artists?.compactMap { $0.name }.joined(separator: ", ")
            let durationSec = track.durationMs.map { Double($0) / 1000.0 }
            return TrackItem(
                id: track.id ?? UUID().uuidString,
                title: track.name ?? "",
                artists: artists,
                imageURL: imageURL,
                hasVideo: false,
                duration: durationSec
            )
        }
        return AlbumItem(title: name, imageURL: imageURL, artists: artistNames, tracks: trackItems)
    }
}

struct SpotifyAlbumTracks: Decodable {
    let items: [SpotifyAlbumTrack?]?
}

struct SpotifyAlbumTrack: Decodable {
    let id: String?
    let name: String?
    let artists: [SpotifyArtistItem]?
    let durationMs: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, artists
        case durationMs = "duration_ms"
    }
}
