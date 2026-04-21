//
//  HomeViewModel.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/8/3.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    @Published var songs: [MusicItem]?
    @Published var playlists: [PlaylistItem]?
    @Published var savedAlbums: [SpotifyUserSavedAlbum]? = nil
    @Published var recentlyPlayed: [SpotifyRecentlyPlayedItem]? = nil

    @Published var newMusic: ItunesMusicVideo?
    @Published var homeSections: [HomeSection]?
    
    private let service: HomeServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(service: HomeServiceProtocol = HomeService()) {
        self.service = service
    }
}
