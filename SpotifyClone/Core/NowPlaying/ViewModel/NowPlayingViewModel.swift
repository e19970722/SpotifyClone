//
//  NowPlayingViewModel.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/9/17.
//

import Foundation
import AVFoundation
import Combine

enum PlayingPlatform {
    case none
    case headphone
    case computer
}

enum PlayingDevice: String {
    case none
    case bluetooth
}

class NowPlayingViewModel: ObservableObject {
    @Published var currentSong: TrackItem? = nil
    @Published var isPlaying: Bool = false
    @Published var isSeeking: Bool = false
    @Published var progress: Double = 0.0
    @Published var lastProgressDrag: Double = 0.0
    @Published var currentDuration: Double = 0.0
    @Published var totalDuration: Double = 0.0
    
    @Published var playingPlatform: PlayingPlatform = .headphone
    @Published var playingDevice: PlayingDevice = .bluetooth
    @Published var deviceName = "My Device"

    private var player: AVPlayer?
    private var currentSongSubscription: AnyCancellable?
    private let nowPlayingService: NowPlayingServiceProtocol

    init(nowPlayingService: NowPlayingServiceProtocol = NowPlayingService()) {
        self.nowPlayingService = nowPlayingService
        addCurrentSongSubscription()
    }

    private func addCurrentSongSubscription() {
        currentSongSubscription = $currentSong
            .sink { [weak self] track in
                guard let self = self, let track = track else { return }
                self.loadPlayer(track: track)
            }
    }
    
    func loadPlayer(track: TrackItem) {
        player?.pause()
        player = nil
        progress = 0.0
        lastProgressDrag = 0.0
        totalDuration = 0.0
        currentDuration = 0.0
        
        Task {
            if let urlString = try await nowPlayingService.fetchPreviewUrl(trackName: track.title),
               let url = URL(string: urlString) {
                player = AVPlayer(url: url)
                addMusicTimeObserver()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let self = self else { return }
                    self.play()
                }
            }
        }
    }

    func play() {
        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    private func addMusicTimeObserver() {
        player?.addPeriodicTimeObserver(
            forInterval: .init(seconds: 1, preferredTimescale: 1), queue: .main
        ) { [weak self] time in
            guard let self = self else { return }
            if let currentPlayerItem = player?.currentItem {
                let totalDuration = currentPlayerItem.duration.seconds
                guard totalDuration > 0,
                      let currentDuration = player?.currentTime().seconds else { return }
                
                DispatchQueue.main.async {
                    self.currentDuration = currentDuration
                    self.totalDuration = totalDuration
                }
                
                let calculatedProgress = currentDuration / totalDuration
                
                if !isSeeking {
                    progress = max(min(calculatedProgress, 1), 0)
                    lastProgressDrag = progress
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if calculatedProgress == 1 {
                        self.player?.seek(to: .zero)
                        self.progress = .zero
                        self.lastProgressDrag = .zero
                        self.player?.play()
                    }
                }
            }
        }
    }
}
