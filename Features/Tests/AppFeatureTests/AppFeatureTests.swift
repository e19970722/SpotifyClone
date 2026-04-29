import ComposableArchitecture
import XCTest
@testable import Features

@MainActor
final class FeaturesTests: XCTestCase {
    func testAppLaunch() throws {
        let store = TestStore(
            initialState: AppFeature.State(),
            reducer: { AppFeature() }
        )
    }
}
