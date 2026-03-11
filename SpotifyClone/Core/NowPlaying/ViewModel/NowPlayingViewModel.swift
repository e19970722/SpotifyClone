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
    
    // ⚠️ TODO: 傳入真實播放值
    @Published var isPlaying: Bool = false
    @Published var currentSong: MusicItem = DeveloperPreview.instance.currentSong
    @Published var currentProgress: Double = 0.0
    @Published var playingPlatform: PlayingPlatform = .headphone
    @Published var playingDevice: PlayingDevice = .bluetooth
    @Published var deviceName = DeveloperPreview.instance.deviceName
    /// 目前播到幾秒
    @Published var currentTimerSec: Double = 0.0
    
    private var player: AVPlayer?
    private var playingTimeSubscription: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        addObserver()
    }
    
    private func addObserver() {
        self.$currentTimerSec
            .sink { [weak self] sec in
                guard let self = self,
                      let duration = currentSong.duration else { return }
                if self.currentTimerSec > duration {
                    self.pause()
                } else {
                    self.currentProgress = sec / duration
                }
                print("**** currentSec: \(self.currentTimerSec)")
            }
            .store(in: &cancellables)
    }
    
    func loadSong(song: MusicItem) {
        if let songURLString = self.currentSong.songUrl,
           let musicURL = URL(string: songURLString) {
            player = AVPlayer(url: musicURL)
        }
    }
    
    func play() {
        print("***** Start Playing")
        guard let duration = currentSong.duration else { return }
        if self.currentTimerSec == duration {
            self.currentTimerSec = 0.0
        }
        
        playingTimeSubscription?.cancel()
        playingTimeSubscription = nil
        playingTimeSubscription = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .scan(self.currentTimerSec, { (sec, _ ) in
                return sec + 1.0
            })
            /// Timer繼續存活的條件
            .prefix{ sec in
                return sec <= duration
            }
            .sink(receiveCompletion: { [weak self] _ in
                guard let self = self else { return }
                self.isPlaying = false
                print("***** Timer Completed")
                
            }, receiveValue: { [weak self] sec in
                guard let self = self else { return }
                self.currentTimerSec = sec
            })
        
        self.player?.play()
        self.isPlaying = true
    }
    
    func pause() {
        print("***** Stop Playing")
        self.player?.pause()
        self.isPlaying = false
        self.playingTimeSubscription?.cancel()
        self.playingTimeSubscription = nil
    }
}
