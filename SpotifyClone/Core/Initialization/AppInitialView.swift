//
//  AppInitialView.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2025/10/27.
//

import SwiftUI

struct AppInitialView: View {
    
    @StateObject private var userManager: UserManager
    
    @State private var isLoading: Bool = false
    @State private var showLogin: Bool = false
    
    init() {
        _userManager = StateObject(wrappedValue: UserManager.instance)
    }
        
	var body: some View {
        ZStack {
            Color.black
            
            if isLoading {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black)
                
            } else if !showLogin {
                AppTabBarView()
            }
        }
        .environmentObject(userManager)
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
                .environmentObject(userManager)
        }
        .onChange(of: userManager.isLoading) { isLoadingUser in
            self.isLoading = isLoadingUser
        }
        .onChange(of: userManager.needLogin) { isNeedLogin in
            self.showLogin = isNeedLogin
        }
	}
}

#Preview {
	AppInitialView()
}
