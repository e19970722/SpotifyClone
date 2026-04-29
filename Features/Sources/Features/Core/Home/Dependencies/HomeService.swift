//
//  HomeService.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/12.
//

import Foundation
import Dependencies

struct HomeService {
    var fetchUserPlaylists: (Int, Int) async throws -> SpotifyUserPlaylistResponse
    var fetchSavedAlbums: (Int, Int) async throws -> SpotifyUserSavedAlbumsResponse
    var fetchRecentlyPlayed: (Int) async throws -> SpotifyRecentlyPlayedResponse
}

extension HomeService: DependencyKey {
    static var liveValue: HomeService = {
        let network: NetworkManagerProtocol = NetworkManager()
        return HomeService(
            fetchUserPlaylists: { limit, offset in
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
            },
            
            fetchSavedAlbums: { limit, offset in
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
            },
            
            fetchRecentlyPlayed: { limit in
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
        )
    }()
}

extension DependencyValues {
    var homeService: HomeService {
        get { self[HomeService.self] }
        set { self[HomeService.self] = newValue }
    }
}
