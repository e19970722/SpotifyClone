//
//  PlaylistCollectionSectionView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/9/15.
//

import SwiftUI

/// 4x2
struct PlaylistCollectionSectionView: View {
    
    let playlists: [ItunesAlbum]
    
    var body: some View {
        GeometryReader { geo in
            // 3個8px的Spacing
            let singleHeight = (geo.size.height - (3 * 8)) / 4

            let twoColums: [GridItem] = [
                // spacing 控制左右
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 0)
            ]
            // spacing 控制上下
            LazyVGrid(columns: twoColums, spacing: 8) {
                ForEach(playlists) { playlist in
                    if let artworkUrlStr = playlist.artworkUrl100,
                       let artworkUrl = URL(string: artworkUrlStr),
                       let title = playlist.collectionName {
                        PlaylistCollectionView(imageURL: artworkUrl,
                                               title: title)
                        .frame(height: singleHeight)
                    }
                }
            }
        }
    }
}
