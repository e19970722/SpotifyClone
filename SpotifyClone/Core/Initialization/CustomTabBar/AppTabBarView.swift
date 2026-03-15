//
//  AppTabBarView.swift
//  WellNewProject
//
//  Created by Yen Lin on 2025/12/5.
//

import SwiftUI

struct AppTabBarView: View {    
     
    @State private var tabSelection: TabBarItem = .home
    @State private var oldTabSelection: TabBarItem = .home
    @State private var isTabBarVisible: Bool = true
    @State private var tabBarHeight: CGFloat = 0.0
    
    // MARK: - 重複點擊 Tab 事件
    
    @State private var onTapSameTabFirst: Bool = false
    @State private var onTapSameTabSecond: Bool = false
    @State private var onTapSameTabThird: Bool = false
    @State private var onTapSameTabForth: Bool = false
    @State private var onTapSameTabFifth: Bool = false
    @State private var onTapSameTabSixth: Bool? = false
    
    // MARK: - 跳轉 App 導頁事件
    
    @State private var openUserID: String? = nil
    @State private var openArticleID: String? = nil
    
    // MARK: - Body
    
    var body: some View {
        CustomTabBarContainerView(selection: $tabSelection,
                                  isTabBarVisible: $isTabBarVisible,
                                  tabBarHeight: $tabBarHeight,
                                  content: {
                                        homeTab
                                        searchTab
                                        libraryTab
                                        createTab
                                    },
                                  onTapSameTab: handleOnTapSameTab)
        .environment(\.isTabBarVisible, $isTabBarVisible)
        .environment(\.tabBarHeight, tabBarHeight)
        .environment(\.tabSelection, tabSelection)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    AppTabBarView()
}

extension AppTabBarView {
    private var homeTab: some View {
        HomeView()
            .tabBarItem(tab: .home, selection: $tabSelection)
    }
    
    private var searchTab: some View {
        Color.black.ignoresSafeArea()
            .tabBarItem(tab: .search, selection: $tabSelection)
    }
    
    private var libraryTab: some View {
        Color.black.ignoresSafeArea()
            .tabBarItem(tab: .library, selection: $tabSelection)
    }
    
    private var createTab: some View {
        Color.black.ignoresSafeArea()
            .tabBarItem(tab: .create, selection: $tabSelection)
    }
            
    private func handleOnTapSameTab(_ sameTab: TabBarItem) {
        switch sameTab.rawValue {
        case 0:
            onTapSameTabFirst.toggle()
        
        case 1:
            onTapSameTabSecond.toggle()
        
        case 2:
            onTapSameTabThird.toggle()
            
        case 3:
            onTapSameTabForth.toggle()
            
        case 4:
            onTapSameTabFifth.toggle()
            
        case 5:
            onTapSameTabSixth?.toggle()
            
        default:
            break
        }
    }
}
