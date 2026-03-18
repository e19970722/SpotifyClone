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
            if !isPresentOAuth {
                isPresentOAuth = true
                Task {
                    if let accessToken = try? await OAuthManager.instance.loginWithSpotify() {
                        try? KeychainManager.shared.save(accessToken, forKey: .accessToken)
                        userManager.isLoggedIn = true
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
                .background(.greenColor1)
                .clipShape(RoundedRectangle(cornerRadius: 36))
                .padding(.horizontal, 48)
        }
    }
}
