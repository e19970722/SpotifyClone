//
//  HomeEnum.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/15.
//

enum HomeSegmentType: Hashable, CaseIterable {
    case all
    case music
    case podcasts
    
    var title: String {
        switch self {
        case .all:              return "All"
        case .music:            return "Music"
        case .podcasts:         return "Podcasts"
        }
    }
}

enum HomePath: Hashable {
    case detailView(id: String)
}
