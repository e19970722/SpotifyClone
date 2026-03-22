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
    
    @State private var selectedSegment: HomeSegmentType = .all
    
    private var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    init() {
        _homeVM = StateObject(wrappedValue: HomeViewModel())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            mainInfoView
            
            ScrollView(.vertical, showsIndicators: false) {
                mainListView
            }
        }
        .clipShape(Rectangle())
        .background(Color.theme.background)
        .onAppear {
            homeVM.fetchAlbums(artistName: "Mariah Carey", count: 8)
            homeVM.fetchMusicVideos(artistName: "Mariah Carey")
        }
        .onTabAppear(tab: .home) {
            homeVM.fetchAlbums(artistName: "Mariah Carey", count: 8)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserManager.instance)
}

extension HomeView {
    
    private var mainInfoView: some View {
        HStack(alignment: .center, spacing: 8) {
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
                PlaylistCollectionSectionView(playlists: playlist)
                    .frame(height: screenHeight * (257/874))
                    .padding(.horizontal, .design.padding16)
            }
            
            if let newMusicItem = homeVM.newMusic {
                newMusicView(newMusicItem)
            }
            
            if let homeSections = homeVM.homeSections {
                homeSectionsView(homeSections)
            }
        }
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
}
