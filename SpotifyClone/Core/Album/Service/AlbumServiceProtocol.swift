//
//  AlbumServiceProtocol.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/4/23.
//

import Foundation

protocol AlbumServiceProtocol {
    func fetchAlbum(id: String) async throws -> SpotifyAlbumDetail
}
