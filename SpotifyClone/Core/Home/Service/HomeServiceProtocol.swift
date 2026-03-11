//
//  HomeServiceProtocol.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/12.
//

import Foundation

protocol HomeServiceProtocol {
    func fetchAlbums(artistName: String, count: Int) async throws -> [ItunesAlbum]
}
