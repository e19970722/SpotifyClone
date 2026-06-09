//
//  AppInitialView.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2025/10/27.
//

import SwiftUI

struct AppInitialView: View {
    
    @StateObject private var userManager: UserManager
        
    init() {
        _userManager = StateObject(wrappedValue: UserManager.instance)
    }
        
	var body: some View {
        ZStack {
            Color.black
            
            if userManager.isLoading {
                loadingView
                
            } else if userManager.needLogin {
                LoginView()
                    .environmentObject(userManager)
                
            } else {
                AppTabBarView()
            }
        }
        .environmentObject(userManager)
	}
}

#Preview {
	AppInitialView()
}

extension AppInitialView {
    private var loadingView: some View {
        ProgressView()
            .tint(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
    }
}
