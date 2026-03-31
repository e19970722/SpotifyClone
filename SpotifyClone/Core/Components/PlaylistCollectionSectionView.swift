//
//  PlaylistCollectionSectionView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/9/15.
//

import SwiftUI

/// 4x2
struct PlaylistCollectionSectionView: View {
    
    let playlists: [PlaylistItem]
    let onTap: (PlaylistItem) -> Void
    
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
                    if let title = playlist.title {
                        PlaylistCollectionView(imageURL: playlist.imageURL,
                                               title: title)
                        .frame(height: singleHeight)
                        .onTapGesture {
                            onTap(playlist)
                        }
                    }
                }
            }
        }
    }
}
