//
//  PlaylistServiceProtocol.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/4/1.
//

import Foundation

protocol PlaylistServiceProtocol {
    func fetchPlaylist(id: String) async throws -> SpotifyPlaylistDetail
}
