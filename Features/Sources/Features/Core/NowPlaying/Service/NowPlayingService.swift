//
//  NowPlayingService.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/4/22.
//

import Foundation

protocol NowPlayingServiceProtocol {
    func fetchPreviewUrl(trackName: String) async throws -> String?
}

final class NowPlayingService: NowPlayingServiceProtocol {

    private let network: NetworkManagerProtocol
    private let itunesBaseURL = URL(string: "https://itunes.apple.com")!

    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func fetchPreviewUrl(trackName: String) async throws -> String? {
        let endpoint = Endpoint(
            baseURL: itunesBaseURL,
            path: "search",
            queryItems: [
                URLQueryItem(name: "term",  value: trackName),
                URLQueryItem(name: "media", value: "music"),
                URLQueryItem(name: "limit", value: "1")
            ]
        )
        let response: ItunesTrackResponse = try await network.request(endpoint)
        return response.results?.first?.previewUrl
    }
}
