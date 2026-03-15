//
//  AppInitialView.swift
//  WellNewProject
//
//  Created by Yen Lin on 2025/10/27.
//

import SwiftUI

struct AppInitialView: View {
    
    var isLoggedIn: Bool = true
    
	var body: some View {
        Group {
            if isLoggedIn {
                AppTabBarView()
            }
        }
	}
}

#Preview {
	AppInitialView()
}
