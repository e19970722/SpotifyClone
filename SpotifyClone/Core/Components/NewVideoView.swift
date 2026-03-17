//
//  NewVideoView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/8/3.
//

import AVFoundation
import SwiftUI
import Kingfisher

struct NewVideoView: View {
    
    let thumbnailURL: URL?
    let videoURL: URL?
    
    var body: some View {
        ZStack {
            KFImage(thumbnailURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
            
            videoView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .foregroundColor(.white)
        .background(Color.theme.newMusicVideoView)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    NewVideoView(thumbnailURL: URL(string: ""), videoURL: URL(string: ""))
        .frame(height: 300)
}

extension NewVideoView {
    
    private var videoView: some View {
        CustomVideoPlayer(videoURL: videoURL)
            .overlay {
                controlView
            }
    }
    
    private var controlView: some View {
        VStack {
            upperView
            Spacer()
            lowerView
        }
        .padding(.all, 16)
    }
    
    private var upperView: some View {
        HStack {
            Spacer()
            Image(systemName: "ellipsis")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
    }
    
    private var lowerView: some View {
        HStack {
            previewSoundBtnView
            Spacer()
            HStack(spacing: 24) {
                Image(systemName: "plus.circle")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
            }
        }
    }
    
    private var previewSoundBtnView: some View {
        HStack(spacing: 8) {
            Image(systemName: "speaker.slash")
            Text("Preview single")
                .font(.system(size: 12, weight: .semibold))
        }
        .padding(.all, 16)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(cgColor: CGColor(red: 6/255,
                                             green: 6/255,
                                             blue: 6/255,
                                             alpha: 1)))
        }
    }
}
