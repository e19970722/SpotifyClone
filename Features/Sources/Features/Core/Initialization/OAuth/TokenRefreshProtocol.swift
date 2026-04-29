//
//  TokenRefreshProtocol.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/4/16.
//

protocol TokenRefreshProtocol {
    func refreshAccessToken(refreshToken: String) async throws -> SpotifyTokenResponse
}
