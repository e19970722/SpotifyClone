//
//  AppInitialView.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2025/10/27.
//

import ComposableArchitecture
import SwiftUI

struct AppInitialView: View {
    
    @StateObject private var userManager: UserManager
    
    let store: StoreOf<AppFeature>
    
    init() {
        self.store = .init(initialState: AppFeature.State(), reducer: { AppFeature() })
        _userManager = StateObject(wrappedValue: UserManager.instance)
    }
        
	var body: some View {
        ZStack {
            Color.black
            
            if userManager.isLoading {
                loadingView
                
            } else if userManager.needLogin {
                LoginView()
                
            } else {
                AppTabBarView(store: store)
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
