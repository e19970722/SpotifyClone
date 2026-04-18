//
//  PlaylistService.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/4/1.
//

import Foundation

final class PlaylistService: PlaylistServiceProtocol {

    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func fetchPlaylist(id: String) async throws -> SpotifyPlaylistDetail {
        let endpoint = Endpoint(
            baseURL: SpotifyAPI.baseURL,
            path: "playlists/\(id)",
            headers: SpotifyAPI.authHeader
        )
        return try await network.request(endpoint)
    }
}
