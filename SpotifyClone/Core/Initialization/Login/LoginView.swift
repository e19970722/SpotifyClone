//
//  LoginView.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/18.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var userManager: UserManager
    
    var body: some View {
        ZStack {
            Color.greyColor1.ignoresSafeArea()
            loginButton
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(UserManager.instance)
}

extension LoginView {
    private var loginButton: some View {
        Button {
            Task {
                if let accessToken = try? await OAuthManager.instance.loginWithSpotify() {
                    SpotifyUserDefaults.shared.accessToken = accessToken
                    userManager.isLoggedIn = true
                }
            }
            
        } label: {
            Text("Login")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 16)
                .background(.greenColor1)
                .clipShape(RoundedRectangle(cornerRadius: 36))
                .padding(.horizontal, 48)
        }
    }
}
