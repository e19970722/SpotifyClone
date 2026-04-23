//
//  NewMusicView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/9/16.
//

import SwiftUI

import Kingfisher

struct NewMusicView: View {
    
    let item: ItunesMusicVideo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            newMusicInfoView
            
            if let urlString = item.previewUrl {
                NewVideoView(thumbnailURL: URL(string: urlString),
                             videoURL: URL(string: urlString))
            }
        }
    }
}

#Preview {
    NewMusicView(item: ItunesMusicVideo(artistName: nil, trackName: nil, artworkUrl100: nil, previewUrl: nil))
        .frame(width: 380, height: UIScreen.main.bounds.height * 0.4)
        .background(.black)
}

extension NewMusicView {
    
    private var newMusicInfoView: some View {
        return HStack(alignment: .center) {
            if let urlString = item.artworkUrl100,
               let url = URL(string: urlString) {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("New Music Video From \(item.artistName ?? "")")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(item.trackName ?? "")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
