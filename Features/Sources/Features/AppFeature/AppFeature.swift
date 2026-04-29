// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import SwiftUI

struct AppFeature: Reducer {
    struct State: Equatable { }
    
    enum Action: Equatable { }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> { }
}
