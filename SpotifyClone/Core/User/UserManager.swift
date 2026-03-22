//
//  UserManager.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/18.
//

import Combine
import SwiftUI

final class UserManager: ObservableObject {
    
    static let instance = UserManager()
    
    @Published var isLoggedIn: Bool = false
    @Published var defaultUser: SpotifyUser? = nil

    private let service: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    
    private init(service: UserServiceProtocol = UserService()) {
        self.service = service

        self.isLoggedIn = KeychainManager.shared.read(forKey: .accessToken) != nil
        if self.isLoggedIn {
            fetchUserInfo()
        }
    }
    
    func addSubscription() {
        $isLoggedIn
            .sink { [weak self] isLoggedIn in
                guard let self = self else { return }
                if isLoggedIn {
                    self.fetchUserInfo()
                }
            }
            .store(in: &cancellables)
    }

    func logout() {
        try? KeychainManager.shared.delete(forKey: .accessToken)
        try? KeychainManager.shared.delete(forKey: .refreshToken)
        isLoggedIn = false
    }
    
    private func fetchUserInfo() {
        Task {
            if let user = try? await service.fetchCurrentUser() {
                await MainActor.run {
                    self.defaultUser = user
                }
            }
        }
    }
    
    func userImageURL() -> URL? {
        print("***** \(defaultUser?.images?.first?.url ?? "")")
        return URL(string: defaultUser?.images?.first?.url ?? "")
    }
}
