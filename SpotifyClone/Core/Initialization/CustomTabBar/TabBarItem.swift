//
//  TabBarItem.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2025/12/5.
//

public enum TabBarIconState: String, CaseIterable, Hashable {
    case normal
    case highlight
}

public enum TabBarItem: Int, Hashable {
    case home                  = 0
    case search                = 1
    case library               = 2
    case create                = 3
    
    /// 標題名稱
    var title: String {
        switch self {
        case .home:                     return "Home"
        case .search:                   return "Search"
        case .library:                  return "Your Library"
        case .create:                   return "Create"
        }
    }
    
    /// 一般狀態 Icon
    var normalIconImageName: String {
        switch self {
        case .home:                     return "house"
        case .search:                   return "magnifyingglass.circle"
        case .library:                  return "folder"
        case .create:                   return "plus"
        }
    }
    
    /// 選擇後狀態 Icon
    var hightlightIconImageName: String {
        switch self {
        case .home:                     return "house.fill"
        case .search:                   return "magnifyingglass.circle.fill"
        case .library:                  return "folder.fill"
        case .create:                   return "plus"
        }
    }
}
