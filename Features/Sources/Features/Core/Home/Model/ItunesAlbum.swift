//
//  ItunesAlbum.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/12.
//

import Foundation

struct ItunesAlbumResponse: Decodable {
    let results: [ItunesAlbum]?
}

struct ItunesAlbum: Codable, Identifiable {
    let collectionId: Int?
    let collectionName: String?
    let artistName: String?
    let artworkUrl100: String?
    var id: Int? { collectionId }
}
