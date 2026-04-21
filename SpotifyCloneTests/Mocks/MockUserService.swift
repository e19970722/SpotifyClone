//
//  MockUserService.swift
//  SpotifyCloneTests
//
//  Created by Yen Lin on 2026/4/16.
//

@testable import SpotifyClone

final class MockUserService: UserServiceProtocol {

    func fetchCurrentUser() async throws -> SpotifyUser {
        SpotifyUser(
            id: "mock_user",
            displayName: "Mock User",
            email: "mock@test.com",
            country: nil,
            product: nil,
            href: nil,
            uri: nil,
            images: nil,
            followers: nil,
            externalUrls: nil
        )
    }

    func fetchUserPlaylists(limit: Int, offset: Int) async throws -> SpotifyUserPlaylistResponse {
        SpotifyUserPlaylistResponse(playlists: [])
    }
}
