// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import SwiftUI

struct AppFeature: Reducer {
    struct State: Equatable {
        var home: HomeFeature.State = .init()
    }
    
    enum Action: Equatable {
        case home(HomeFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.home, action: /Action.home) {
            HomeFeature()
        }
        
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .home:
            return .none
        }
    }
}
