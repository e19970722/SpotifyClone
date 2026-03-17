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
    @Published var playlists: [ItunesAlbum]?
    @Published var newMusic: ItunesMusicVideo?
    @Published var homeSections: [HomeSection]?

    private let service: HomeServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(service: HomeServiceProtocol = HomeService()) {
        self.service = service
    }

    func fetchAlbums(artistName: String, count: Int) {
        Task { @MainActor in
            do {
                let albums = try await service.fetchAlbums(artistName: artistName, count: count) ?? []
                self.playlists = albums
            } catch {
                print("fetchAlbums error: \(error)")
            }
        }
    }
    
    func fetchMusicVideos(artistName: String) {
        Task { @MainActor in
            do {
                let newMusic = try await service.fetchMusicVideos(artistName: artistName, count: 1)
                if let firstNewMusic = newMusic?.first {
                    self.newMusic = firstNewMusic
                }
                
            } catch {
                print("fetchAlbums error: \(error)")
            }
        }
    }
}
