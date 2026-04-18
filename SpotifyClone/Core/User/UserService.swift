//
//  UserService.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/19.
//

import Foundation

final class UserService: UserServiceProtocol {

    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func fetchCurrentUser() async throws -> SpotifyUser {
        let endpoint = Endpoint(
            baseURL: SpotifyAPI.baseURL,
            path: "me",
            headers: SpotifyAPI.authHeader
        )
        return try await network.request(endpoint)
    }
    
    func fetchUserPlaylists(limit: Int, offset: Int) async throws -> SpotifyUserPlaylistResponse {
        let endpoint = Endpoint(
            baseURL: SpotifyAPI.baseURL,
            path: "me/playlists",
            headers: SpotifyAPI.authHeader,
            queryItems: [
                URLQueryItem(name: "limit",  value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ]
        )
        return try await network.request(endpoint)
    }

    func fetchSavedAlbums(limit: Int, offset: Int) async throws -> SpotifyUserSavedAlbumsResponse {
        let endpoint = Endpoint(
            baseURL: SpotifyAPI.baseURL,
            path: "me/albums",
            headers: SpotifyAPI.authHeader,
            queryItems: [
                URLQueryItem(name: "limit",  value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ]
        )
        return try await network.request(endpoint)
    }

    func fetchRecentlyPlayed(limit: Int) async throws -> SpotifyRecentlyPlayedResponse {
        let endpoint = Endpoint(
            baseURL: SpotifyAPI.baseURL,
            path: "me/player/recently-played",
            headers: SpotifyAPI.authHeader,
            queryItems: [
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        )
        return try await network.request(endpoint)
    }
}
