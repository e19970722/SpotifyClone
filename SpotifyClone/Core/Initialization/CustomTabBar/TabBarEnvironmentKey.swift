//
//  TabBarEnvironmentKey.swift
//  WellNewProject
//
//  Created by Yen Lin on 2026/1/13.
//

import Foundation
import SwiftUI

struct TabBarVisibleEnvironmentKey: EnvironmentKey {
    static let defaultValue: Binding<Bool>? = nil
}

struct TabBarHeightEnvironmentKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0.0
}

struct TabBarSelectionEnvironmentKey: EnvironmentKey {
    static let defaultValue: TabBarItem = .home
}

public extension EnvironmentValues {
    var isTabBarVisible: Binding<Bool>? {
        get {
            self[TabBarVisibleEnvironmentKey.self]
        }
        set {
            self[TabBarVisibleEnvironmentKey.self] = newValue
        }
    }
    
    var tabBarHeight: CGFloat {
        get {
            self[TabBarHeightEnvironmentKey.self]
        }
        set {
            self[TabBarHeightEnvironmentKey.self] = newValue
        }
    }
    
    var tabSelection: TabBarItem {
        get {
            self[TabBarSelectionEnvironmentKey.self]
        }
        set {
            self[TabBarSelectionEnvironmentKey.self] = newValue
        }
    }
}
