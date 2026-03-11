//
//  HomeView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/8/3.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var vm: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            MainInfoView(profileImageName: vm.user?.userImage ?? "Profile")
            mainListView
        }
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .background(Color.theme.background)
    }
}

#Preview {
    HomeView()
        .environmentObject(DeveloperPreview.instance.vm)
    
}

extension HomeView {
    
    private var mainListView: some View {
        let bottomPadding = 24.0
        let screenHeight = UIScreen.main.bounds.height
        return List {
            playlistsSectionView(screenHeight: screenHeight, bottomPadding: bottomPadding)
            newMusicSectionView(screenHeight: screenHeight, bottomPadding: bottomPadding)
            homeSectionsView(screenHeight: screenHeight, bottomPadding: bottomPadding)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private func playlistsSectionView(screenHeight: CGFloat, bottomPadding: CGFloat) -> some View {
        Section {
            if let playlist = vm.playlists {
                PlaylistCollectionSectionView(playlists: playlist)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .frame(height: screenHeight * (257/874))
            }
        }
        .listRowBackground(Color.clear)
        .padding(.bottom, bottomPadding)
    }
    
    private func newMusicSectionView(screenHeight: CGFloat, bottomPadding: CGFloat) -> some View {
        return Section {
            if let newMusic = vm.newMusic {
                NewMusicView(artistImage: newMusic.artistImage ?? "",
                             newMusic: newMusic,
                             videoImage: newMusic.videoImage ?? "")
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .frame(height: screenHeight * 0.3)
            }
        }
        .listRowBackground(Color.clear)
        .padding(.bottom, bottomPadding)
    }
    
    /// @ViewBuilder用於條件式顯示View與否
     @ViewBuilder
     private func homeSectionsView(screenHeight: CGFloat, bottomPadding: CGFloat) -> some View {
         if let homeSections = vm.homeSections, !homeSections.isEmpty {
             ForEach(homeSections) { section in
                 Section {
                     HomeSectionView(section: section)
                         .listRowSeparator(.hidden)
                         .listRowInsets(EdgeInsets())
                         .frame(height: screenHeight * section.heightPortion)
                 }
                 .listRowBackground(Color.clear)
                 .padding(.bottom, bottomPadding)
             }
         }
     }
}
