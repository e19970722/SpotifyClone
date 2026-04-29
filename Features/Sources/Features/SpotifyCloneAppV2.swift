//
//  SwiftUIView.swift
//  Features
//
//  Created by Yen Lin on 2026/4/29.
//

import ComposableArchitecture
import SwiftUI

@main
struct SpotifyCloneAppV2: App {
    var body: some Scene {
        WindowGroup {
            AppInitialView()
        }
    }
}

struct AppFeature: Reducer {
    struct State: Equatable { }
    
    enum Action: Equatable { }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> { }
}
