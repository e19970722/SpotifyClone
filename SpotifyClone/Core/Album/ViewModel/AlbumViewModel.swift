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

    init(playlistService: PlaylistServiceProtocol = PlaylistService()) {
        self.playlistService = playlistService
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
}
