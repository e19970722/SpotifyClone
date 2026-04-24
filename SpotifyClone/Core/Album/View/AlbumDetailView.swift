//
//  AlbumDetailView.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/22.
//

import SwiftUI
import Kingfisher

struct AlbumDetailView: View {
    @Environment(\.tabBarHeight) private var tabBarHeight
    @EnvironmentObject private var nowPlayingVM: NowPlayingViewModel
    
    @StateObject private var albumVM: AlbumViewModel
    
    @State private var scrollOffset: Double = 0.0
    
    let albumID: String
    private let isPlaylist: Bool

    private var album: AlbumItem {
        return albumVM.albumItem
    }
    
    private var tracks: [TrackItem] {
        return album.tracks ?? []
    }

    init(albumID: String) {
        self.albumID = albumID
        self.isPlaylist = false
        _albumVM = StateObject(wrappedValue: AlbumViewModel())
    }

    init(playlistID: String) {
        self.albumID = playlistID
        self.isPlaylist = true
        _albumVM = StateObject(wrappedValue: AlbumViewModel())
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                headerView
                infoSectionView
                actionBarView
                genreTagsView
                trackListView
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.frame(in: .named("scroll")).minY) { value in
                            scrollOffset = -Double(value)
                        }
                }
            )
        }
        .coordinateSpace(name: "scroll")
        .padding(.bottom, tabBarHeight)
        .background(
            LinearBackgroundView(mainColor: .purple)
                .ignoresSafeArea()
        )
        .onAppear {
            if isPlaylist {
                albumVM.fetchPlaylist(id: albumID)
            } else {
                albumVM.fetchAlbum(id: albumID)
            }
        }
    }
}

#Preview {
    AlbumDetailView(albumID: "")
        .environmentObject(NowPlayingViewModel())
}

// MARK: - Sub-views
extension AlbumDetailView {

    private var headerView: some View {
        let componentWidth = 240.0
        let scaled = scrollOffset > 0 ? (componentWidth - scrollOffset) / componentWidth : 1.0
        return KFImage(album.imageURL)
            .resizable()
            .scaledToFit()
            .frame(width: componentWidth, height: componentWidth)
            .background(.black)
            .opacity(scaled)
            .scaleEffect(scaled, anchor: .center)
            .clipShape(RoundedRectangle(cornerRadius: .design.padding8))
            .padding(.top, .design.padding16)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var infoSectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = album.title, !title.isEmpty {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }

            if let description = album.description, !description.isEmpty {
                Text(description)
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
                    .lineSpacing(4)
            }

            if let duration = album.duration, !duration.isEmpty {
                Text(duration)
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
            }
        }
        .padding(.horizontal, .design.padding16)
        .padding(.top, 12)
    }

    private var actionBarView: some View {
        HStack(spacing: 16) {
            KFImage(album.imageURL)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .background(.black)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color.theme.green)

            Image(systemName: "arrow.down.circle")
                .font(.system(size: 24))
                .foregroundStyle(.gray)

            Image(systemName: "ellipsis")
                .font(.system(size: 24))
                .foregroundStyle(.gray)

            Spacer()

            Button {
                nowPlayingVM.isShuffle.toggle()
                
            } label: {
                Image(systemName: "shuffle")
                    .font(.system(size: 22))
                    .foregroundStyle(nowPlayingVM.isShuffle ? Color.theme.green : .gray)
            }

            let isContain = tracks.contains(where: { $0.id == nowPlayingVM.currentSong?.id })
            Button {
                nowPlayingVM.isPlaying.toggle()
                guard !isContain else { return }
                
                if nowPlayingVM.isShuffle,
                   let randomIndex = (0...tracks.count-1).randomElement() {
                    nowPlayingVM.loadPlayer(album: album,
                                            tracks: tracks,
                                            selectedTrack: tracks[randomIndex])
                    
                } else if let firstTrack = tracks.first {
                    nowPlayingVM.loadPlayer(album: album,
                                            tracks: tracks,
                                            selectedTrack: firstTrack)
                }
                
            } label: {
                Image(systemName: (nowPlayingVM.isPlaying && isContain) ? "pause.fill" : "play.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.black)
                    .frame(width: 52, height: 52)
                    .background(Color.theme.green)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, .design.padding16)
    }

    @ViewBuilder
    private var genreTagsView: some View {
        if let tags = album.tags, !tags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(album.tags ?? [], id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.theme.secondaryBtn)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, .design.padding16)
                .padding(.bottom, 8)
            }
        }
    }

    private var trackListView: some View {
        VStack(spacing: 0) {
            ForEach(tracks) { track in
                trackCellView(track)
            }
        }
    }

    private func trackCellView(_ track: TrackItem) -> some View {
        HStack(alignment: .center, spacing: 12) {
            KFImage(track.imageURL)
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    if track.hasVideo {
                        Image(systemName: "play.rectangle")
                            .font(.system(size: 11))
                            .foregroundStyle(.gray)
                        Text("Video")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                        Text("•")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                    }

                    if let artists = track.artists {
                        Text(artists)
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.theme.green)

            Image(systemName: "ellipsis")
                .font(.system(size: 18))
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, .design.padding16)
        .padding(.vertical, 10)
        .contentShape(.rect)
        .onTapGesture {
            nowPlayingVM.loadPlayer(album: album,
                                    tracks: tracks,
                                    selectedTrack: track)
        }
    }
}

// MARK: - Helpers
extension AlbumDetailView {
    private func getArtistNames() -> AttributedString? {
        guard let artists = album.artists else { return nil }
        var combinedStr = AttributedString("")
        for (index, artist) in artists.enumerated() {
            if index < 3 {
                var currentStr = index == artists.count - 1 || index == 2
                    ? AttributedString("\(artist)")
                    : AttributedString("\(artist), ")
                currentStr.font = .system(size: 13, weight: .semibold)
                currentStr.foregroundColor = .white
                combinedStr += currentStr
            }
        }

        if artists.count > 3 {
            var lastStr = AttributedString(" and more")
            lastStr.font = .system(size: 13)
            lastStr.foregroundColor = UIColor.lightGray
            combinedStr += lastStr
        }
        return combinedStr
    }
}
