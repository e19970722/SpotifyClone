//
//  HomeView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/8/3.
//

import SwiftUI
import Kingfisher

struct HomeView: View {
    @EnvironmentObject private var userManager: UserManager
    
    @StateObject private var homeVM: HomeViewModel
    
    @State private var path = NavigationPath()
    @State private var selectedSegment: HomeSegmentType = .all
    
    private var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    private var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
        
    init() {
        _homeVM = StateObject(wrappedValue: HomeViewModel())
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: .design.padding16) {
                mainInfoView
                
                ScrollView(.vertical) {
                    mainListView
                }
            }
            .background(Color.theme.background)
            .onAppear {
//                homeVM.fetchAlbums(artistName: "Mariah Carey", count: 8)
//                homeVM.fetchMusicVideos(artistName: "Mariah Carey")
            }
            .onTabAppear(tab: .home) {
//                homeVM.fetchAlbums(artistName: "Mariah Carey", count: 8)
            }
            .navigationDestination(
                for: HomePath.self,
                destination: decideNavigationForHomePath
            )
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserManager.instance)
}

// MARK: - Navigation Path

extension HomeView {
    @ViewBuilder
    private func decideNavigationForHomePath(_ route: HomePath) -> some View {
        switch route {
        case .detailView(let id):
            AlbumDetailView(albumID: id)
        case .playlistView(let id):
            AlbumDetailView(playlistID: id)
        }
    }
}

// MARK: - Extension

extension HomeView {
    
    private var mainInfoView: some View {
        HStack(alignment: .center, spacing: .design.padding8) {
            KFImage(userManager.userImageURL())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
                .clipShape(Circle())
            
            ForEach(HomeSegmentType.allCases, id: \.self) { segment in
                FillSegmentBtnView(isSelected: Binding(
                    get: { selectedSegment == segment },
                    set: { isSelected in
                        selectedSegment = isSelected ? segment : .all}
                ), title: segment.title)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .design.padding16)
    }
    
    private var mainListView: some View {
        VStack(spacing: 24) {
            if let playlist = userManager.playlists {
                PlaylistCollectionSectionView(playlists: playlist,
                                              onTap: { item in
                    if let id = item.id {
                        path.append(HomePath.playlistView(id: id))
                    }
                })
                .frame(height: screenHeight * (257/874))
                .padding(.horizontal, .design.padding16)
            }
            
//            if let newMusicItem = homeVM.newMusic {
//                newMusicView(newMusicItem)
//            }
            
            if let homeSections = homeVM.homeSections {
                homeSectionsView(homeSections)
            }
            
            if let albums = userManager.savedAlbums {
                VStack(spacing: .design.padding8) {
                    titleView("Your Saved Albums")
                    savedAlbums(albums)
                }
            }

            if let items = userManager.recentlyPlayed {
                VStack(spacing: .design.padding8) {
                    titleView("Recently Played")
                    recentAlbums(items)
                }
            }
        }
    }
    
    private func titleView(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 24, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.white)
            .lineLimit(1)
            .padding(.horizontal, .design.padding16)
    }
    
    private func newMusicView(_ item: ItunesMusicVideo) -> some View {
        NewMusicView(item: item)
            .padding(.horizontal, .design.padding16)
    }
    
    private func homeSectionsView(_ sections: [HomeSection]) -> some View {
         ForEach(sections) { section in
             HomeSectionView(section: section)
                 .frame(height: screenHeight * section.heightPortion)
         }
     }
    
    private func horizontalListView(itemWidth: CGFloat, imageURL: URL?, title: String?) -> some View {
        VStack(spacing: .design.padding8) {
            KFImage(imageURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: itemWidth, height: itemWidth)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            Text(title ?? "")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.gray.opacity(0.6))
                .lineLimit(1)
                .frame(width: itemWidth, alignment: .topLeading)
        }
    }
    
    private func savedAlbums(_ albums: [SpotifyUserSavedAlbum]) -> some View {
        let width = (screenWidth - .design.padding16 * 3) / 2.5
        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: .design.padding16) {
                ForEach(albums) { album in
                    if let albumURLStr = album.images?.first?.url {
                        horizontalListView(itemWidth: width,
                                           imageURL: URL(string: albumURLStr),
                                           title: album.name)
                    }
                }
            }
            .padding(.horizontal, .design.padding16)
        }
    }
    
    private func recentAlbums(_ items: [SpotifyRecentlyPlayedItem]) -> some View {
        let width = (screenWidth - .design.padding16 * 3) / 2.5
        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: .design.padding16) {
                ForEach(items) { item in
                    if let albumURLStr = item.track?.album?.images?.first?.url {
                        horizontalListView(itemWidth: width,
                                           imageURL: URL(string: albumURLStr),
                                           title: item.track?.album?.name)
                    }
                }
            }
            .padding(.horizontal, .design.padding16)
        }
    }
}
