//
//  LoginView.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/18.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var userManager: UserManager
    
    @State private var isPresentOAuth: Bool = false
    
    var body: some View {
        ZStack {
            Color.theme.greyColor1.ignoresSafeArea()
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
            if !isPresentOAuth {
                isPresentOAuth = true
                Task {
                    if let result = try? await OAuthManager.instance.loginWithSpotify() {
                        userManager.saveSession(
                            accessToken: result.accessToken,
                            refreshToken: result.refreshToken,
                            expiresIn: result.expiresIn
                        )
                    }
                    isPresentOAuth = false
                }
            }
            
        } label: {
            Text("Login")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 16)
                .background(Color.theme.green)
                .clipShape(RoundedRectangle(cornerRadius: 36))
                .padding(.horizontal, 48)
        }
    }
}
