//
//  Double+Ext.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/4/23.
//

import Foundation

extension Double {
    
    func formatTimeStr() -> String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
