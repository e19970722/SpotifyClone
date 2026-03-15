//
//  CustomTabBarView.swift
//  WellNewProject
//
//  Created by Yen Lin on 2025/10/29.
//

import SwiftUI

struct CustomTabBarView: View {

    let tabs: [TabBarItem]
    let onTapSameTab: (_ sameTab: TabBarItem) -> Void
    @Binding var selection: TabBarItem

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                tabBarImageView(tab: tab)
            }
        }
        .padding(.top, 12)
        .padding(.horizontal, 8)
        .background(.black)
    }
}

#Preview {
    let tabs: [TabBarItem] = [.home, .search, .library, .create]
    CustomTabBarView(tabs: tabs, onTapSameTab: { _ in }, selection: .constant(.home))
}

extension CustomTabBarView {
    
    private func tabBarImageView(tab: TabBarItem) -> some View {
        return Button {
            if tab == selection {
                onTapSameTab(tab)
                
            } else {
                switchToTab(tab)
            }
            
        } label: {
            VStack(spacing: 4) {
                tabIconImageView(tab: tab)

                Text(tab.title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.greyColor1)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func switchToTab(_ tab: TabBarItem) {
        selection = tab
    }
    
    private func tabIconImageView(tab: TabBarItem) -> some View {
        let iconImage = (selection == tab) ? tab.hightlightIconImageName : tab.normalIconImageName
        return Image(systemName: iconImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .tint(.greyColor1)
            .frame(width: 36, height: 36)
    }
}
