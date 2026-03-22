//
//  UserServiceProtocol.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/19.
//

import Foundation

protocol UserServiceProtocol {
    func fetchCurrentUser() async throws -> SpotifyUser
    func fetchUserPlaylists(limit: Int, offset: Int) async throws -> SpotifyUserPlaylistResponse
}
