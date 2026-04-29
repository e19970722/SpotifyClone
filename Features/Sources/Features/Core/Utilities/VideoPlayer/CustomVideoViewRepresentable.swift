//
//  CustomVideoPlayer.swift
//  CustomVideoPlayer
//
//  Created by Yen Lin on 2026/1/26.
//

import AVKit
import SwiftUI

struct CustomVideoViewRepresentable: UIViewControllerRepresentable {
    
    var player: AVPlayer?
    
    func makeUIViewController(context: Context) -> some AVPlayerViewController {
        let vc = AVPlayerViewController()
        vc.player = player
        vc.showsPlaybackControls = false
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
