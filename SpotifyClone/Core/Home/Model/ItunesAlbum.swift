//
//  ItunesAlbum.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/12.
//

import Foundation

struct ItunesSearchResponse: Decodable {
    let results: [ItunesAlbum]
}

struct ItunesAlbum: Decodable {
    let collectionId: Int
    let collectionName: String
    let artistName: String
    let artworkUrl100: String
}
