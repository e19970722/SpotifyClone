//
//  HomeFeature.swift
//  Features
//
//  Created by Yen Lin on 2026/4/29.
//

import ComposableArchitecture
import SwiftUI

struct HomeFeature: Reducer {
    struct State: Equatable {
        var playlists: [PlaylistItem]? = nil
        var savedAlbums: [SpotifyUserSavedAlbum]? = nil
        var recentlyPlayed: [SpotifyRecentlyPlayedItem]? = nil
    }
    
    enum Action: Equatable {
        // MARK: - Input Event
        case onAppear
        case fetchHomeData
        case playlistDidTapped
        case savedAlbumsDidTapped
        case recentlyPlayedDidTapped
        
        // MARK: - Output Event
        case playlistLoaded(playlists: [PlaylistItem]?)
        case savedAlbumsLoaded(savedAlbums: [SpotifyUserSavedAlbum]?)
        case recentlyPlayedLoaded(recentlyPlayed: [SpotifyRecentlyPlayedItem]?)
    }
    
    @Dependency(\.homeService) var homeService
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        // MARK: - Input Event
        case .onAppear:
            return .send(.fetchHomeData)
            
        case .fetchHomeData:
            return .run { send in
                await fetchHomeData(send: send)
            }
        
        // MARK: - Output Event
        case let .playlistLoaded(playlist):
            state.playlists = playlist
            return .none
            
        case let .savedAlbumsLoaded(savedAlbums):
            state.savedAlbums = savedAlbums
            return .none
            
        case let .recentlyPlayedLoaded(recentlyPlayed):
            state.recentlyPlayed = recentlyPlayed
            return .none
            
        default:
            return .none
        }
    }
}

extension HomeFeature {
    func fetchHomeData(send: Send<HomeFeature.Action>) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                if let returnedValued = try? await self.homeService.fetchUserPlaylists(8, 0) {
                    await send(.playlistLoaded(playlists: returnedValued.playlists))
                }
            }

            group.addTask {
                if let returnedValued = try? await self.homeService.fetchSavedAlbums(10, 0) {
                    await send(.savedAlbumsLoaded(savedAlbums: returnedValued.items?.compactMap { $0.album }))
                }
            }

            group.addTask {
                if let returnedValued = try? await self.homeService.fetchRecentlyPlayed(10) {
                    await send(.recentlyPlayedLoaded(recentlyPlayed: returnedValued.items))
                }
            }
        }
    }
}
