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
    
}
