//
//  SpotifyCloneApp.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/11.
//

import SwiftUI
import AVFoundation

@main
struct SpotifyCloneApp: App {
    
    init() {
        configureAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            AppInitialView()
        }
    }
}

extension SpotifyCloneApp {
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .moviePlayback,
                options: []
            )
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch {
            print("❌ AVAudioSession setup failed: \(error)")
        }
    }
}
