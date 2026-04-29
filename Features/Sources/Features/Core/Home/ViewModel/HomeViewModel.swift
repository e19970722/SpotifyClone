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
        
    func fetchData() {
//        Task {
//            await withTaskGroup { [weak self] group in
//                guard let self = self else { return }
//                group.addTask {
//                    if let returnedValued = try? await self.service.fetchUserPlaylists(limit: 8, offset: 0),
//                       let playlists = returnedValued.playlists {
//                        await MainActor.run {
//                            self.playlists = playlists
//                        }
//                    }
//                }
//                
//                group.addTask {
//                    if let returnedValued = try? await self.service.fetchSavedAlbums(limit: 10, offset: 0) {
//                        let savedAlbums = returnedValued.items?.compactMap { $0.album }
//                        await MainActor.run {
//                            self.savedAlbums = savedAlbums
//                        }
//                    }
//                }
//                
//                group.addTask {
//                    if let returnedValued = try? await self.service.fetchRecentlyPlayed(limit: 10),
//                       let recentlyPlayed = returnedValued.items {
//                        await MainActor.run {
//                            self.recentlyPlayed = recentlyPlayed
//                        }
//                    }
//                }
//            }
//        }
    }
}
