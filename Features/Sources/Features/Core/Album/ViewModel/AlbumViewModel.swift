//
//  AlbumViewModel.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/30.
//

import Foundation
import Combine

class AlbumViewModel: ObservableObject {

    @Published var albumItem: AlbumItem = .init(title: "")

    private let playlistService: PlaylistServiceProtocol
    private let albumService: AlbumServiceProtocol

    init(
        playlistService: PlaylistServiceProtocol = PlaylistService(),
        albumService: AlbumServiceProtocol = AlbumService()
    ) {
        self.playlistService = playlistService
        self.albumService = albumService
    }

    func fetchPlaylist(id: String) {
        Task { @MainActor in
            do {
                let detail = try await playlistService.fetchPlaylist(id: id)
                albumItem = detail.toAlbumItem()
            } catch {
                print("fetchPlaylist error: \(error)")
            }
        }
    }

    func fetchAlbum(id: String) {
        Task { @MainActor in
            do {
                let detail = try await albumService.fetchAlbum(id: id)
                albumItem = detail.toAlbumItem()
            } catch {
                print("fetchAlbum error: \(error)")
            }
        }
    }
}
