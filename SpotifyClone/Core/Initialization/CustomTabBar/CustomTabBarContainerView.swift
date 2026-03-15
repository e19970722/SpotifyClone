//
//  CustomTabBarContainerView.swift
//  WellNewProject
//
//  Created by Yen Lin on 2025/12/5.
//

import SwiftUI

struct CustomTabBarContainerView<Content: View>: View {
        
    @Binding private var selection: TabBarItem
    @Binding private var isTabBarVisible: Bool
    @Binding private var tabBarHeight: CGFloat
    
    @State private var tabs: [TabBarItem] = []
    
    let content: Content
    let onTapSameTab: (_ sameTab: TabBarItem) -> Void
    
    init(selection: Binding<TabBarItem>,
         isTabBarVisible: Binding<Bool>,
         tabBarHeight: Binding<CGFloat>,
         @ViewBuilder content: () -> Content,
         onTapSameTab: @escaping (_ sameTab: TabBarItem) -> Void) {
        self._selection = selection
        self._isTabBarVisible = isTabBarVisible
        self._tabBarHeight = tabBarHeight
        self.content = content()
        self.onTapSameTab = onTapSameTab
    }
    
    var body: some View {
        ZStack {
            content
        }
        .overlay(alignment: .bottom) {
            if isTabBarVisible {
                CustomTabBarView(tabs: tabs,
                                 onTapSameTab: onTapSameTab,
                                 selection: $selection)
                    .overlay(
                        GeometryReader { geo in
                            Color.clear
                                .updateTabBarHeight(geo.size.height)
                        }
                    )
            }
        }
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
                              onTapSameTab: { sameTab in
        
    })
}
