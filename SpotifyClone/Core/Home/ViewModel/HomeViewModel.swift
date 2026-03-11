//
//  HomeViewModel.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/8/3.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    // TODO
    @Published var profileImageName: String = "person.circle"
    
    @Published var user: User?
    @Published var songs: [MusicItem]?
    @Published var playlists: [PlaylistItem]?
    @Published var newMusic: NewMusicItem?
    @Published var homeSections: [HomeSection]?
    
}
