//
//  CustomTabBarContainerView.swift
//  WellNewProject
//
//  Created by Yen Lin on 2025/12/5.
//

import SwiftUI

struct CustomTabBarContainerView<Content: View>: View {
    @EnvironmentObject private var nowPlayingVM: NowPlayingViewModel
        
    @Binding private var selection: TabBarItem
    @Binding private var isTabBarVisible: Bool
    @Binding private var tabBarHeight: CGFloat
    
    @State private var tabs: [TabBarItem] = []
    
    let content: Content
    let onTapSameTab: (_ sameTab: TabBarItem) -> Void
    let onTapNowPlaying: () -> Void
    
    init(selection: Binding<TabBarItem>,
         isTabBarVisible: Binding<Bool>,
         tabBarHeight: Binding<CGFloat>,
         @ViewBuilder content: () -> Content,
         onTapSameTab: @escaping (_ sameTab: TabBarItem) -> Void,
         onTapNowPlaying: @escaping () -> Void)
    {
        self._selection = selection
        self._isTabBarVisible = isTabBarVisible
        self._tabBarHeight = tabBarHeight
        self.content = content()
        self.onTapSameTab = onTapSameTab
        self.onTapNowPlaying = onTapNowPlaying
    }
    
    var body: some View {
        ZStack {
            content
        }
        .overlay(alignment: .bottom) { bottomView }
        .onPreferenceChange(TabBarItemPreferenceKey.self) { value in
            self.tabs = value
        }
        .onPreferenceChange(TabBarHeightPreferenceKey.self) { value in
            self.tabBarHeight = value
        }
    }
}

#Preview {
    let tabs: [TabBarItem] = [.home, .search, .library, .create]
    CustomTabBarContainerView(selection: .constant(tabs.first!),
                              isTabBarVisible: .constant(true),
                              tabBarHeight: .constant(83),
                              content: {
                                    EmptyView()
                                },
                              onTapSameTab: { _ in },
                              onTapNowPlaying: { }
    )
}

extension CustomTabBarContainerView {
    
    private var bottomView: some View {
        VStack(spacing: 4) {
            if nowPlayingVM.currentSong != nil {
                NowPlayingView()
                    .padding(.horizontal, .design.padding16)
                    .onTapGesture {
                        onTapNowPlaying()
                    }
            }
            
            if isTabBarVisible {
                CustomTabBarView(tabs: tabs,
                                 onTapSameTab: onTapSameTab,
                                 selection: $selection)
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .onChange(of: geo.size.height) { bottomHeight in
                        self.tabBarHeight = bottomHeight
                    }
            }
        )
    }
}
