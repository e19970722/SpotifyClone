# SpotifyClone — Project Guide for Claude

## Project Overview
A Spotify clone built in SwiftUI as a practice project, following MVVM architecture with feature-based folder organization.

## Architecture

### Folder Structure
```
SpotifyClone/
├── Core/
│   ├── <Feature>/          # e.g. Home/, NowPlaying/
│   │   ├── Model/
│   │   ├── ViewModel/
│   │   └── View/
│   ├── Components/         # Reusable UI components
│   │   └── Buttons/
│   ├── Network/            # Networking layer (stub, to be implemented)
│   └── Initialization/     # App root and DI setup
└── Extensions/             # Design system, previews
    ├── Color+Ext.swift
    ├── CGFloat+Ext.swift
    └── PreviewProvider.swift
```

### MVVM Conventions
- **ViewModel**: `ObservableObject` with `@Published` properties; named `<Feature>ViewModel`
- **View injection**: Views receive the VM via `@EnvironmentObject private var vm: <Feature>ViewModel`
- **Root injection**: `AppInitialView` creates VMs with `@StateObject` and injects via `.environmentObject()`
- **Combine**: Use `AnyCancellable` + `sink` + `store(in:)` for reactive logic

## UI / View Coding Style

### Body = Clean & Readable
Keep `body` minimal — reference named sub-views instead of inlining layout code:

```swift
var body: some View {
    VStack(alignment: .leading, spacing: 16) {
        mainInfoView
        ScrollView(.vertical, showsIndicators: false) {
            mainListView
        }
    }
    .background(Color.theme.background)
}
```

### Extensions for Sub-Views
All private sub-views and helper methods go in an `extension` of the same file:

```swift
extension HomeView {
    private var mainInfoView: some View { ... }
    private var mainListView: some View { ... }
    private func newMusicView(_ item: NewMusicItem) -> some View { ... }
}
```

### Sizing
- Prefer a `private var screenHeight: CGFloat { UIScreen.main.bounds.height }` computed property over inline `GeometryReader` where possible
- `GeometryReader` is acceptable but avoid unnecessary ones (ongoing refactor)
- Use proportional sizing: `screenHeight * 0.3`

### Design System
Always use the shared design tokens — do not hardcode color literals or magic numbers:

```swift
Color.theme.background      // Colors via Color+Ext.swift
Color.theme.green
.design.padding16           // CGFloat spacing via CGFloat+Ext.swift
```

Extend the design system if a new token is needed.

### Reusable Components
- Place in `Core/Components/` (or `Core/Components/Buttons/` for buttons)
- Pass data as plain parameters — no ViewModel injection in components
- Use `@Binding` for state that must sync back to parent

### Preview
- All previews use `DeveloperPreview.instance` for mock data
- Inject `.environmentObject(DeveloperPreview.instance.vm)` in previews that need a VM

## Models
- Conform to `Identifiable` (always), `Codable` when API-ready
- Use `UUID().uuidString` for default IDs
- Use `enum` for layout/type variants (e.g. `SectionLayout`)
- **All properties in Decodable/Codable models must be optional** (`String?`, `Int?`, `[T]?`, etc.) — API responses may omit any field at any time

## Networking
- `NetworkManager.swift` is the single networking entry point (currently a stub)
- Models use `Decodable` (not `Codable`) for API response types — encoding is not needed and avoids conformance issues with nested `Decodable`-only types

## Current Refactor Goal
Remove unnecessary `GeometryReader` usages and replace with `UIScreen.main.bounds` proportional sizing where appropriate.
