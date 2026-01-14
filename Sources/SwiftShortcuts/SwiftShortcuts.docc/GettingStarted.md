# Getting Started

Add shortcut tiles to your SwiftUI app.

## Overview

SwiftShortcuts displays Apple Shortcuts as tappable tiles. You can either provide an iCloud share URL for automatic metadata fetching, or specify the details manually.

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/aeastr/SwiftShortcuts.git", from: "1.0.0")
]
```

Then import it:

```swift
import SwiftShortcuts
```

## URL-Based Tiles

Provide an iCloud share URL and the tile fetches metadata automatically:

```swift
ShortcutTile(url: "https://www.icloud.com/shortcuts/abc123")
```

The tile extracts the shortcut ID from the URL, fetches the name, icon, and gradient from iCloud, then displays them. Tapping opens the shortcut in the Shortcuts app.

## Manual Tiles

Specify the details yourself for full control:

```swift
ShortcutTile(name: "Morning Routine", systemImage: "sun.horizon.fill", url: "...")
    .foregroundStyle(ShortcutGradient.orange)
```

Use any SF Symbol for the icon and choose from 15 built-in gradients.

## Styling

Apply the compact style for list layouts:

```swift
VStack {
    ShortcutTile(name: "Quick Note", systemImage: "note.text", url: "...")
    ShortcutTile(name: "Start Timer", systemImage: "timer", url: "...")
}
.shortcutTileStyle(.compact)
```

## Custom Styles

Create your own styles by conforming to ``ShortcutTileStyle``:

```swift
struct MyTileStyle: ShortcutTileStyle {
    func makeBody(configuration: ShortcutTileStyleConfiguration) -> some View {
        VStack {
            if let icon = configuration.icon {
                icon.resizable().frame(width: 60, height: 60)
            }
            Text(configuration.name)
        }
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .padding()
        .background(configuration.gradient ?? ShortcutGradient.gray)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

## Custom Tap Actions

Override the default tap behavior by passing an action closure:

```swift
ShortcutTile(id: "abc123") { url in
    // Custom action instead of opening shortcuts app
    print("Tapped: \(url)")
}
```

## Available Gradients

``ShortcutGradient`` provides all 15 colors from the Shortcuts app:

- `red`, `orange`, `yellow`, `green`, `teal`, `blue`, `purple`, `pink`
- `darkOrange`, `lightBlue`, `darkBlue`, `lightPurple`
- `gray`, `greenGray`, `brown`

Each gradient adapts automatically to light and dark mode.
