//
//  AlbumService.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/4/23.
//

import Foundation

final class AlbumService: AlbumServiceProtocol {

    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func fetchAlbum(id: String) async throws -> SpotifyAlbumDetail {
        let endpoint = Endpoint(
            baseURL: SpotifyAPI.baseURL,
            path: "albums/\(id)",
            headers: SpotifyAPI.authHeader
        )
        return try await network.request(endpoint)
    }
}
