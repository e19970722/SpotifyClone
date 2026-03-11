//
//  PlaylistCollectionSectionView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/9/15.
//

import SwiftUI

/// 4x2
struct PlaylistCollectionSectionView: View {
    
    var playlists: [PlaylistItem]
    
    var body: some View {
        GeometryReader { geo in
            // 3個8px的Spacing
            let singleHeight = (geo.size.height - (3 * 8)) / 4
            
            var displayPlaylist = playlists[0...6]
            let likedPlaylist = PlaylistItem(imageName: "heart",
                                             title: "Liked Songs",
                                             durationSum: "2h 50m")
            displayPlaylist.insert(likedPlaylist, at: 0)
            let twoColums: [GridItem] = [
                // spacing 控制左右
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 0)
            ]
            // spacing 控制上下
            return LazyVGrid(columns: twoColums, spacing: 8) {
                ForEach(displayPlaylist) { playlist in
                    PlaylistCollectionView(imageName: playlist.imageName,
                                           title: playlist.title)
                    .frame(height: singleHeight)
                }
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let collectionViewHeight = UIScreen.main.bounds.size.height * (257/874)
    PlaylistCollectionSectionView(playlists: DeveloperPreview.instance.playLists)
        .frame(height: collectionViewHeight)
}
