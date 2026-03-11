//
//  NewVideoView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/8/3.
//

import SwiftUI

struct NewVideoView: View {
    
    var videoImage: String
    
    var body: some View {
        ZStack {
            Image(videoImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
            videoView
                .padding(.all, 16)

        }
        .frame(maxWidth: .infinity,
               maxHeight: .infinity,
               alignment: .topLeading)
        .foregroundColor(.white)
        .background(Color.theme.newMusicVideoView)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    NewVideoView(videoImage: DeveloperPreview.instance.newMusic.videoImage ?? "NewMusicVideo")
        .frame(height: 300)
}

extension NewVideoView {
    
    private var videoView: some View {
        VStack {
            upperView
            Spacer()
            lowerView
        }
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
