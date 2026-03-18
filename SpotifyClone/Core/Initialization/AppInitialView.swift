//
//  AppInitialView.swift
//  WellNewProject
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
        Group {
            if userManager.isLoggedIn {
                AppTabBarView()
                
            } else {
                LoginView()
            }
        }
        .environmentObject(userManager)
	}
}

#Preview {
	AppInitialView()
}
