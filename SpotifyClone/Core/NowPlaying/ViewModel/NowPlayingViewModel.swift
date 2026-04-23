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
    @Published var currentAlbum: AlbumItem? = nil
    @Published var currentTracks: [TrackItem]? = nil
    @Published var currentSong: TrackItem? = nil
    @Published var isShuffle: Bool = false
    @Published var isRepeat: Bool = false
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
    private var playingSubscription: AnyCancellable?
    private let nowPlayingService: NowPlayingServiceProtocol

    init(nowPlayingService: NowPlayingServiceProtocol = NowPlayingService()) {
        self.nowPlayingService = nowPlayingService
        self.addPlayingStateSubscription()
    }

    func addPlayingStateSubscription() {
        playingSubscription = $isPlaying
            .sink { [weak self] isPlay in
                guard let self = self else { return }
                if isPlay {
                    player?.play()
                    
                } else {
                    player?.pause()
                }
            }
    }

    func loadPlayer(album: AlbumItem? = nil, tracks: [TrackItem], selectedTrack: TrackItem) {
        currentAlbum = album
        currentTracks = tracks
        player?.pause()
        player = nil
        progress = 0.0
        lastProgressDrag = 0.0
        totalDuration = 0.0
        currentDuration = 0.0
        currentSong = selectedTrack

        Task {
            if let urlString = try await nowPlayingService.fetchPreviewUrl(trackName: selectedTrack.title),
               let url = URL(string: urlString) {
                player = AVPlayer(url: url)
                addMusicTimeObserver()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let self = self else { return }
                    self.player?.play()
                    self.isPlaying = true
                }
            }
        }
    }

    func playNext() {
        guard let tracks = currentTracks, !tracks.isEmpty,
              let currentSong = currentSong,
              let currentIndex = tracks.firstIndex(where: { $0.id == currentSong.id }) else { return }

        let nextTrack: TrackItem
        if isShuffle {
            let others = (0..<tracks.count).filter { $0 != currentIndex }
            guard let randomIndex = others.randomElement() else { return }
            nextTrack = tracks[randomIndex]
            
        } else {
            let nextIndex = currentIndex + 1
            if nextIndex < tracks.count {
                nextTrack = tracks[nextIndex]
                
            } else if let firstTrack = tracks.first {
                nextTrack = firstTrack
                
            } else {
                return
            }
        }
        loadPlayer(tracks: tracks, selectedTrack: nextTrack)
    }

    func playPrevious() {
        guard let tracks = currentTracks, !tracks.isEmpty,
              let currentSong = currentSong,
              let currentIndex = tracks.firstIndex(where: { $0.id == currentSong.id }) else { return }

        // Restart current song if played more than 3 seconds
        if currentDuration > 3 {
            playerSeek(to: 0)
            return
        }

        let prevTrack: TrackItem
        if isShuffle {
            let others = (0..<tracks.count).filter { $0 != currentIndex }
            guard let randomIndex = others.randomElement() else { return }
            prevTrack = tracks[randomIndex]
            
        } else {
            let prevIndex = currentIndex - 1
            if prevIndex >= 0 {
                prevTrack = tracks[prevIndex]
                
            } else if let lastTrack = tracks.last {
                prevTrack = lastTrack
                
            } else {
                return
            }
        }
        loadPlayer(tracks: tracks, selectedTrack: prevTrack)
    }

    func playerSeek(to progress: Double) {
        guard let playerItem = player?.currentItem else { return }
        let totalDuration = playerItem.duration.seconds
        playerItem.seek(to: .init(seconds: totalDuration * progress, preferredTimescale: 1))
        { [weak self] isFinished in
            guard let self = self else { return }
            if isFinished {
                DispatchQueue.main.async {
                    self.isSeeking = false
                }
            }
        }
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
                        if self.isRepeat {
                            self.player?.seek(to: .zero)
                            self.progress = .zero
                            self.lastProgressDrag = .zero
                            self.player?.play()
                        } else {
                            self.playNext()
                        }
                    }
                }
            }
        }
    }
}
