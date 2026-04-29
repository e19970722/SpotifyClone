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
}
