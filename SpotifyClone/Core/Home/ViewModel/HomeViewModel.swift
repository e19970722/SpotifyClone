//
//  HomeViewModel.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/8/3.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var songs: [MusicItem]?
    @Published var playlists: [PlaylistItem]?
    @Published var newMusic: NewMusicItem?
    @Published var homeSections: [HomeSection]?

    private let service: HomeServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(service: HomeServiceProtocol = HomeService()) {
        self.service = service
    }

    func fetchAlbums(artistName: String, count: Int) {
        Task { @MainActor in
            do {
                let albums = try await service.fetchAlbums(artistName: artistName, count: count)
                self.playlists = albums.map { Self.mapToPlaylistItem($0) }
            } catch {
                print("fetchAlbums error: \(error)")
            }
        }
    }

    static func mapToPlaylistItem(_ album: ItunesAlbum) -> PlaylistItem {
        let hiResURLString = album.artworkUrl100.replacingOccurrences(of: "100x100", with: "600x600")
        let imageURL = URL(string: hiResURLString)
        return PlaylistItem(
            id: String(album.collectionId),
            imageURL: imageURL,
            title: album.collectionName,
            artists: [album.artistName],
            durationSum: ""
        )
    }
}
