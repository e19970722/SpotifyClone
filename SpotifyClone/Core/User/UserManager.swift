//
//  UserManager.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/18.
//

import Combine
import SwiftUI

final class UserManager: ObservableObject {
    // MARK: - Public

    static let instance = UserManager()
    
    @Published var isLoggedIn: Bool = false
    @Published var defaultUser: SpotifyUser? = nil
    @Published var playlists: [PlaylistItem]? = nil

    // MARK: - Private

    private let service: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private init(service: UserServiceProtocol = UserService()) {
        self.service = service

        self.isLoggedIn = KeychainManager.shared.read(forKey: .accessToken) != nil
        if self.isLoggedIn {
            fetchHomeInfo()
        }
    }
    
    // MARK: - Public Functions

    func logout() {
        try? KeychainManager.shared.delete(forKey: .accessToken)
        try? KeychainManager.shared.delete(forKey: .refreshToken)
        isLoggedIn = false
    }
    
    func userImageURL() -> URL? {
        print("***** \(defaultUser?.images?.first?.url ?? "")")
        return URL(string: defaultUser?.images?.first?.url ?? "")
    }
    
    // MARK: - Private Functions
    
    private func addSubscription() {
        $isLoggedIn
            .sink { [weak self] isLoggedIn in
                guard let self = self else { return }
                if isLoggedIn {
                    self.fetchHomeInfo()
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchHomeInfo() {
        Task {
            if let user = try? await service.fetchCurrentUser() {
                await MainActor.run {
                    self.defaultUser = user
                }
            }
            
            if let returnedValue = try? await service.fetchUserPlaylists(limit: 8, offset: 0),
               let playlists = returnedValue.playlists {
                await MainActor.run {
                    self.playlists = playlists
                }
            }
        }
    }
}
