//
//  CustomTabBarView.swift
//  SpotifyClone
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
                let isSelected = (selection == tab)

                tabIconImageView(isSelected: isSelected, tab: tab)

                Text(tab.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : Color.theme.greyColor1)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func switchToTab(_ tab: TabBarItem) {
        selection = tab
    }
    
    private func tabIconImageView(isSelected: Bool, tab: TabBarItem) -> some View {
        let iconImage = isSelected ? tab.hightlightIconImageName : tab.normalIconImageName
        return Image(systemName: iconImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .tint(isSelected ? .white : Color.theme.greyColor1)
            .frame(width: 24, height: 24)
    }
}
