//
//  HomeService.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/12.
//

import Foundation

final class HomeService: HomeServiceProtocol {

    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func fetchAlbums(artistName: String, count: Int) async throws -> [ItunesAlbum] {
        let endpoint = Endpoint(
            baseURL: URL(string: "https://itunes.apple.com")!,
            path: "search",
            queryItems: [
                URLQueryItem(name: "term",   value: artistName),
                URLQueryItem(name: "entity", value: "album"),
                URLQueryItem(name: "limit",  value: "\(count)")
            ]
        )
        let response: ItunesSearchResponse = try await network.request(endpoint)
        return response.results
    }
}
