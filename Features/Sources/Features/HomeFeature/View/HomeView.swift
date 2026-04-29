//
//  HomeView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/8/3.
//

import ComposableArchitecture
import SwiftUI
import Kingfisher

struct HomeView: View {
    @EnvironmentObject private var userManager: UserManager
    @Environment(\.tabBarHeight) private var tabBarHeight
        
    @Binding var onTapSameTab: Bool
    
    @State private var path = NavigationPath()
    @State private var selectedSegment: HomeSegmentType = .all
    
    let store: StoreOf<HomeFeature>
    
    private var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    private var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
        
    init(store: StoreOf<HomeFeature>, onTapSameTab: Binding<Bool>) {
        self.store = store
        _onTapSameTab = onTapSameTab
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
                store.send(.onAppear)
            }
            .onTabAppear(tab: .home) {
                store.send(.onAppear)
            }
            .navigationDestination(
                for: HomePath.self,
                destination: decideNavigationForHomePath
            )
            .onChange(of: onTapSameTab) { _ in
                if !path.isEmpty {
                    path.removeLast(path.count)
                    
                } else {
                    store.send(.onAppear)
                }
            }
        }
    }
}

#Preview {
    HomeView(store: .init(initialState: HomeFeature.State(),
                          reducer: { HomeFeature() }),
             onTapSameTab: .constant(false))
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
                .scaledToFit()
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
            playlistsView
            savedAlbumsView
            recentlyPlayedView
        }
        .padding(.bottom, .design.padding16)
        .padding(.bottom, tabBarHeight)
    }
    
    private func titleView(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 24, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.white)
            .lineLimit(1)
            .padding(.horizontal, .design.padding16)
    }
    
    private func horizontalListView(itemWidth: CGFloat, imageURL: URL?, title: String?) -> some View {
        VStack(spacing: .design.padding8) {
            KFImage(imageURL)
                .resizable()
                .scaledToFit()
                .frame(width: itemWidth, height: itemWidth)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .background(.black)
            
            Text(title ?? "")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.gray.opacity(0.6))
                .lineLimit(1)
                .frame(width: itemWidth, alignment: .topLeading)
        }
    }
    
    @ViewBuilder
    private var playlistsView: some View {
        WithViewStore(store, observe: { $0.playlists }) { viewStore in
            if let playlists = viewStore.state {
                PlaylistCollectionSectionView(playlists: playlists,
                                              onTap: { item in
                    if let id = item.id {
                        path.append(HomePath.playlistView(id: id))
                    }
                })
                .frame(height: screenHeight * (257/874))
                .padding(.horizontal, .design.padding16)
            }
        }
    }
    
    private var savedAlbumsView: some View {
        let width = (screenWidth - .design.padding16 * 3) / 2.5
        return VStack(spacing: .design.padding8) {
            titleView("Your Saved Albums")
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: .design.padding16) {
                    WithViewStore(store, observe: { $0.savedAlbums }) { viewStore in
                        if let albums = viewStore.state {
                            ForEach(albums) { album in
                                if let albumURLStr = album.images?.first?.url {
                                    horizontalListView(itemWidth: width,
                                                       imageURL: URL(string: albumURLStr),
                                                       title: album.name)
                                    .onTapGesture {
                                        if let id = album.id {
                                            path.append(HomePath.detailView(id: id))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, .design.padding16)
            }
        }
    }
    
    private var recentlyPlayedView: some View {
        let width = (screenWidth - .design.padding16 * 3) / 2.5
        return VStack(spacing: .design.padding8) {
            titleView("Recently Played")
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: .design.padding16) {
                    WithViewStore(store, observe: { $0.recentlyPlayed }) { viewStore in
                        if let items = viewStore.state {
                            ForEach(items) { item in
                                if let albumURLStr = item.track?.album?.images?.first?.url {
                                    horizontalListView(itemWidth: width,
                                                       imageURL: URL(string: albumURLStr),
                                                       title: item.track?.album?.name)
                                    .onTapGesture {
                                        if let id = item.track?.album?.id {
                                            path.append(HomePath.detailView(id: id))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, .design.padding16)
            }
        }
    }
}
