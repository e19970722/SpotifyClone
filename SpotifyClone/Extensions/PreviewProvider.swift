//
//  PreviewProvider.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/8/3.
//

import Foundation
import SwiftUI

extension PreviewProvider {
    static var dev: DeveloperPreview {
        return DeveloperPreview.instance
    }
}

struct User {
    let userName: String
    let userImage: String
}

class DeveloperPreview {
    static let instance = DeveloperPreview()
    
    private init() {}
    
    lazy var vm: HomeViewModel = {
        var vm = HomeViewModel()
        vm.user = self.user
        vm.songs = self.songs
        vm.playlists = self.playLists
        vm.newMusic = self.newMusic
        vm.homeSections = self.homeSections
        return vm
    }()
    
    let user = User(userName: "Yen Lin", userImage: "Profile")
    
    let artist = "Mariah Carey"
    let song = "We Belong Together"
    let albumImage = "AlbumImage"
    let songUrl = "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview112/v4/95/df/e5/95dfe5ac-efe4-5422-e39d-a015a9cf2b1f/mzaf_10401943975266303767.plus.aac.p.m4a"
    let deviceName = "Yen Lin's Airpods Pro"
    
    lazy var currentSong = MusicItem(artist: self.artist,
                                     artistImageName: "Artist",
                                     songName: self.song,
                                     albumName: self.song,
                                     albumImageName: self.albumImage,
                                     songUrl: self.songUrl,
                                     duration: 29)
    
    
    
    lazy var songs = [
        MusicItem(id: "1",
                  artist: self.artist,
                  artistImageName: "Artist",
                  songName: self.song,
                  albumName: self.song,
                  albumImageName: self.albumImage,
                  songUrl: self.songUrl,
                  duration: 29),
        MusicItem(id: "2",
                  artist: self.artist,
                  artistImageName: "Artist",
                  songName: self.song,
                  albumName: self.song,
                  albumImageName: self.albumImage,
                  songUrl: self.songUrl,
                  duration: 29),
        MusicItem(id: "3",
                  artist: self.artist,
                  artistImageName: "Artist",
                  songName: self.song,
                  albumName: self.song,
                  albumImageName: self.albumImage,
                  songUrl: self.songUrl,
                  duration: 29)
    ]
    
    lazy var playLists = [
        PlaylistItem(imageName: "Collections", title: "Collections", artists: [self.artist, "Taylor Swift", "Demi Lovato"], durationSum: "2h 50m"),
        PlaylistItem(imageName: "Collections", title: "Collections", durationSum: "2h 50m"),
        PlaylistItem(imageName: "Collections", title: "Collections", durationSum: "2h 50m"),
        PlaylistItem(imageName: "Collections", title: "Collections", durationSum: "2h 50m"),
        PlaylistItem(imageName: "Collections", title: "Collections", durationSum: "2h 50m"),
        PlaylistItem(imageName: "Collections", title: "Collections", durationSum: "2h 50m"),
        PlaylistItem(imageName: "Collections", title: "Collections", durationSum: "2h 50m"),
        PlaylistItem(imageName: "Collections", title: "Collections", durationSum: "2h 50m")
    ]
    
    lazy var newMusic = NewMusicItem(artist: self.artist,
                                     song: "We Belong Together (Mimi's Late Night Valentine's Mix)",
                                     artistImage: "Artist", videoImage: "NewMusicVideo")
    
    lazy var homeSections = [
        HomeSection(name: "Your top mixes", albums: self.songs),
        HomeSection(name: "Recents", albums: self.songs, layout: .four),
        HomeSection(name: "Made For \(self.user.userName)", albums: self.songs)
    ]
}
