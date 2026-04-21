//
//  HomeServiceProtocol.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/12.
//

import Foundation

protocol HomeServiceProtocol {
    func fetchAlbums(artistName: String, count: Int) async throws -> [ItunesAlbum]?
    func fetchMusicVideos(artistName: String, count: Int) async throws -> [ItunesMusicVideo]?
    func fetchUserPlaylists(limit: Int, offset: Int) async throws -> SpotifyUserPlaylistResponse
    func fetchSavedAlbums(limit: Int, offset: Int) async throws -> SpotifyUserSavedAlbumsResponse
    func fetchRecentlyPlayed(limit: Int) async throws -> SpotifyRecentlyPlayedResponse
}
