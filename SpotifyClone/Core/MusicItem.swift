//
//  MusicItem.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/9/15.
//

import Foundation

struct MusicItem: Identifiable {
    var id: String = UUID().uuidString
    let artist: String
    let artistImageName: String
    let songName: String
    let albumName: String
    let albumImageName: String
    let songUrl: String?
    let duration: Double?
    
    init(artist: String,
         artistImageName: String,
         songName: String,
         albumName: String,
         albumImageName: String,
         songUrl: String?,
         duration: Double?) {
        self.artist = artist
        self.artistImageName = artistImageName
        self.songName = songName
        self.albumName = albumName
        self.albumImageName = albumImageName
        self.songUrl = songUrl
        self.duration = duration
    }
}
