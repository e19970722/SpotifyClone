//
//  ItunesMusicVideo.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/15.
//

import Foundation

struct ItunesTrackResponse: Decodable {
    let results: [ItunesTrack]?
}

struct ItunesTrack: Decodable {
    let previewUrl: String?
}

struct ItunesMusicVideoResponse: Decodable {
    let results: [ItunesMusicVideo]?
}

struct ItunesMusicVideo: Decodable {
    let artistName: String?
    let trackName: String?
    let artworkUrl100: String?
    let previewUrl: String?
}
