//
//  HomeService.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/12.
//

import Foundation

final class HomeService: HomeServiceProtocol {

    private let network: NetworkManagerProtocol
    private let itunesURL = "https://itunes.apple.com"

    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func fetchAlbums(artistName: String, count: Int) async throws -> [ItunesAlbum]? {
        guard let url = URL(string: itunesURL) else { throw NetworkError.invalidURL }
        let endpoint = Endpoint(
            baseURL: url,
            path: "search",
            queryItems: [
                URLQueryItem(name: "term",   value: artistName),
                URLQueryItem(name: "entity", value: "album"),
                URLQueryItem(name: "limit",  value: "\(count)")
            ]
        )
        let response: ItunesAlbumResponse = try await network.request(endpoint)
        return response.results
    }
    
    func fetchMusicVideos(artistName: String, count: Int) async throws -> [ItunesMusicVideo]? {
        guard let url = URL(string: itunesURL) else { throw NetworkError.invalidURL }
        let endpoint = Endpoint(
            baseURL: url,
            path: "search",
            queryItems: [
                URLQueryItem(name: "term",   value: artistName),
                URLQueryItem(name: "media", value: "musicVideo"),
                URLQueryItem(name: "limit",  value: "\(count)")
            ]
        )
        let response: ItunesMusicVideoResponse = try await network.request(endpoint)
        return response.results
    }
}
