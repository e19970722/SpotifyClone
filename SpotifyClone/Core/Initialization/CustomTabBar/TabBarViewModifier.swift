//
//  TabBarViewModifier.swift
//  WellNewProject
//
//  Created by Yen Lin on 2026/2/6.
//

import SwiftUI

struct HideTabBarModifier: ViewModifier {
    @Environment(\.isTabBarVisible) private var isTabBarVisible
    @State private var previousState: Bool?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                previousState = isTabBarVisible?.wrappedValue
                isTabBarVisible?.wrappedValue = false
            }
            .onDisappear {
                if let previous = previousState {
                    isTabBarVisible?.wrappedValue = previous
                }
            }
    }
}

struct isTabFirstAppearViewModifier: ViewModifier {
    @Environment(\.tabSelection) var tabSelection
    
    @State private var isTabFirstAppear: [TabBarItem: Bool] = [:]
    
    let tab: TabBarItem
    let firstAppearAction: (() -> Void)?
    let appearAction: (() -> Void)?
    
    init(tab: TabBarItem,
         firstAppearAction: (() -> Void)? = nil,
         appearAction: (() -> Void)? = nil)
    {
        self.tab = tab
        self.firstAppearAction = firstAppearAction
        self.appearAction = appearAction
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: tabSelection) { _, selection in
                guard tab == selection else { return }
                
                if isTabFirstAppear[selection] == nil {
                    isTabFirstAppear[selection] = true
                    firstAppearAction?()
                    
                } else if let hasFirstAppeared = isTabFirstAppear[selection], hasFirstAppeared {
                    appearAction?()
                }
            }
    }
}

struct onTabAppearViewModifier: ViewModifier {
    @Environment(\.tabSelection) var tabSelection
        
    let tab: TabBarItem
    let appearAction: (() -> Void)?
    
    init(tab: TabBarItem, appearAction: (() -> Void)? = nil)
    {
        self.tab = tab
        self.appearAction = appearAction
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: tabSelection) { _, selection in
                guard tab == selection else { return }
                appearAction?()
            }
    }
}

extension View {
    func hidesTabBar() -> some View {
        modifier(HideTabBarModifier())
    }
    
    func onTabFirstAppear(tab: TabBarItem, action: @escaping () -> Void) -> some View {
        modifier(isTabFirstAppearViewModifier(tab: tab, firstAppearAction: action))
    }
    
    func onTabAppear(tab: TabBarItem, action: @escaping () -> Void) -> some View {
        modifier(onTabAppearViewModifier(tab: tab, appearAction: action))
    }
}
