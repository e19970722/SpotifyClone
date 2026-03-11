//
//  AppInitialView.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/11.
//

import SwiftUI

struct AppInitialView: View {
    @StateObject private var homeVM: HomeViewModel
    
    init() {
        _homeVM = StateObject(wrappedValue: HomeViewModel())
    }
    
    var body: some View {
        HomeView()
            .environmentObject(homeVM)
    }
}

#Preview {
    AppInitialView()
}
