//
//  CustomVideoPlayer.swift
//  CustomVideoPlayer
//
//  Created by Yen Lin on 2026/1/26.
//

import AVKit
import SwiftUI

struct CustomVideoPlayer: View {
    
    @State private var player: AVPlayer? = nil
    @State private var showPlaybackControls: Bool = true
    @State private var isPlaying: Bool = false
    @State private var isMute: Bool = true
    @State private var isSeeking: Bool = false
    
    @GestureState private var isDragging: Bool = false
    @State private var progress: CGFloat = 0
    @State private var lastProgressDrag: CGFloat = 0
    
    var videoURL: URL?
    
    var body: some View {
        ZStack {
            if let player = player {
                CustomVideoViewRepresentable(player: player)
                
            } else {
                Color.black
                    .overlay(alignment: .center) {
                        ProgressView()
                            .tint(.white)
                    }
            }
        }
        .ignoresSafeArea()
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.35)) {
                showPlaybackControls.toggle()
            }
        }
        .safeAreaInset(edge: .bottom) {
            playbackControls
        }
        .task {
            if let url = videoURL {
                player = AVPlayer(url: url)
            }
            
            addVideoTimeObserver()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isPlaying = true
                player?.play()
            }
        }
    }
}

#Preview {
    CustomVideoPlayer()
}

extension CustomVideoPlayer {
    private var playbackControls: some View {
        HStack(spacing: 0) {
            Button {
                if isPlaying {
                    player?.pause()
                } else {
                    player?.play()
                }
                
                withAnimation(.easeInOut(duration: 0.35)) {
                    isPlaying.toggle()
                }
                
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .padding(8)
            }
            
            seekerView
            
            Button {
                withAnimation(.easeInOut(duration: 0.35)) {
                    isMute.toggle()
                }
                player?.isMuted = isMute
                
            } label: {
                Image(systemName: isMute ? "speaker.wave.1.fill" : "speaker.slash.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .padding(8)
            }
        }
        .opacity(showPlaybackControls ? 1 : 0)
        .padding(.horizontal, 8)
    }
    
    private var seekerView: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.gray)
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .frame(width: max(geo.size.width * progress, 0))
            }
            .overlay(alignment: .leading) {
                Circle()
                    .fill(.white)
                    .frame(width: 16, height: 16)
                    /// For Dragging Space
                    .frame(width: 50, height: 50)
                    .contentShape(Rectangle())
                    /// Moving along with gesture progress
                    .offset(x: (progress == 1) ? geo.size.width * progress - 16 : geo.size.width * progress)
                    .gesture(
                        DragGesture()
                            .updating($isDragging, body: { _, out, _ in
                                out = true
                            })
                            .onChanged({ value in
                                let translationX: CGFloat = value.translation.width
                                let calculatedProgress = (translationX / geo.size.width) + lastProgressDrag
                                progress = max(min(calculatedProgress, 1), 0)
                                
                                isSeeking = true
                            })
                            .onEnded({ value in
                                lastProgressDrag = progress
                                
                                if let currentPlayerItem = player?.currentItem {
                                    let totalDuration = currentPlayerItem.duration.seconds
                                    player?.seek(to: .init(seconds: totalDuration * progress, preferredTimescale: 1))
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        isSeeking = false
                                    }
                                }
                            })
                    )
                    .frame(width: 16, height: 16)
            }
        }
        .frame(height: 4)
    }
    
    private func addVideoTimeObserver() {
        player?.addPeriodicTimeObserver(
            forInterval: .init(seconds: 1, preferredTimescale: 1), queue: .main
        ) { time in
            if let currentPlayerItem = player?.currentItem {
                let totalDuration = currentPlayerItem.duration.seconds
                guard let currentDuration = player?.currentTime().seconds else { return }
                
                let calculatedProgress = currentDuration / totalDuration
                
                if !isSeeking {
                    progress = max(min(calculatedProgress, 1), 0)
                    lastProgressDrag = progress
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if calculatedProgress == 1 {
                        player?.seek(to: .zero)
                        progress = .zero
                        lastProgressDrag = .zero
                        player?.play()
                    }
                }
            }
        }
    }
}
