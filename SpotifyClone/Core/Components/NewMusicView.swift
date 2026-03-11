//
//  NewMusicView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/9/16.
//

import SwiftUI

struct NewMusicView: View {
    
    var artistImage: String
    var newMusic: NewMusicItem
    var videoImage: String
    
    var body: some View {
        GeometryReader { geo in
            let infoHeight = geo.size.width * (9 / 16) * 0.2
            /// 保持影片16:9
            let videoHeight = geo.size.width * (9 / 16)
            
            VStack(alignment: .leading, spacing: 16) {
                newMusicInfoView(height: infoHeight)
                
                NewVideoView(videoImage: videoImage)
                    .frame(height: videoHeight)
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    NewMusicView(artistImage: DeveloperPreview.instance.newMusic.artistImage ?? "",
                 newMusic: DeveloperPreview.instance.newMusic,
                 videoImage: DeveloperPreview.instance.newMusic.videoImage ?? "")
    .frame(width: 380, height: UIScreen.main.bounds.height * 0.4)
    .background(.black)
}

extension NewMusicView {
    
    private func newMusicInfoView(height: CGFloat) -> some View {
        return HStack(alignment: .center) {
            Image(artistImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: height, height: height)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text("New Music Video From \(newMusic.artist)")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(newMusic.song)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
