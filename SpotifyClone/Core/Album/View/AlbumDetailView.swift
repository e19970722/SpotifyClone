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

    @StateObject private var albumVM: AlbumViewModel

    let albumID: String
    private let isPlaylist: Bool

    private var album: AlbumItem {
        return albumVM.albumItem
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
        }
        .padding(.bottom, tabBarHeight)
        .background(
            LinearBackgroundView(mainColor: .purple)
                .ignoresSafeArea()
        )
        .onAppear {
            if isPlaylist {
                albumVM.fetchPlaylist(id: albumID)
            }
        }
    }
}

#Preview {
    AlbumDetailView(albumID: "")
}

// MARK: - Sub-views
extension AlbumDetailView {

    private var headerView: some View {
        KFImage(album.imageURL)
            .resizable()
            .aspectRatio(1.0, contentMode: .fill)
            .padding(.horizontal, 64)
            .padding(.top, 16)
    }

    private var infoSectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let artistText = getArtistNames() {
                Text(artistText)
            }

            madeForView

            aboutView

            if let duration = album.duration {
                Text(duration)
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
            }
        }
        .padding(.horizontal, .design.padding16)
        .padding(.top, 12)
    }

    private var madeForView: some View {
        HStack(spacing: 6) {
            Image(.spotifyIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .clipShape(Circle())

            if let madeFor = album.madeFor {
                Text("Made for ")
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                + Text(madeFor)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var aboutView: some View {
        Group {
            if let description = album.description {
                Text("About ")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                + Text(description)
                    .font(.system(size: 13))
                    .foregroundStyle(.gray)
            }
        }
    }

    private var actionBarView: some View {
        HStack(spacing: 16) {
            KFImage(album.imageURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 44, height: 44)
                .clipped()

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

            Image(systemName: "shuffle")
                .font(.system(size: 22))
                .foregroundStyle(.gray)

            Button {
                // play action
            } label: {
                Image(systemName: "play.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.black)
                    .frame(width: 52, height: 52)
                    .background(Color.theme.green)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, .design.padding16)
    }

    private var genreTagsView: some View {
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

    private var trackListView: some View {
        VStack(spacing: 0) {
            ForEach(album.tracks ?? []) { track in
                trackCellView(track)
            }
        }
    }

    private func trackCellView(_ track: TrackItem) -> some View {
        HStack(alignment: .center, spacing: 12) {
            KFImage(track.imageURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 52, height: 52)
                .background(Color.theme.secondaryBtn)
                .clipped()

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
