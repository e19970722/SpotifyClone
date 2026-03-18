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
    
    private init() {
        
    }
}
