# Getting Started

Add shortcut cards to your SwiftUI app.

## Overview

SwiftShortcuts displays Apple Shortcuts as tappable cards. You can either provide an iCloud share URL for automatic metadata fetching, or specify the details manually.

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

## URL-Based Cards

Provide an iCloud share URL and the card fetches metadata automatically:

```swift
ShortcutCard(url: "https://www.icloud.com/shortcuts/abc123")
```

The card extracts the shortcut ID from the URL, fetches the name, icon, and gradient from iCloud, then displays them. Tapping opens the shortcut in the Shortcuts app.

## Manual Cards

Specify the details yourself for full control:

```swift
ShortcutCard(name: "Morning Routine", systemImage: "sun.horizon.fill", url: "...")
    .foregroundStyle(ShortcutGradient.orange)
```

Use any SF Symbol for the icon and choose from 15 built-in gradients.

## Styling

Apply the compact style for list layouts:

```swift
VStack {
    ShortcutCard(name: "Quick Note", systemImage: "note.text", url: "...")
    ShortcutCard(name: "Start Timer", systemImage: "timer", url: "...")
}
.shortcutCardStyle(.compact)
```

## Custom Styles

Create your own styles by conforming to ``ShortcutCardStyle``:

```swift
struct MyCardStyle: ShortcutCardStyle {
    func makeBody(configuration: ShortcutCardStyleConfiguration) -> some View {
        VStack {
            if let icon = configuration.icon {
                icon.resizable().frame(width: 60, height: 60)
            }
            Text(configuration.name)
        }
        .padding()
        .background(configuration.gradient ?? ShortcutGradient.gray)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

## Available Gradients

``ShortcutGradient`` provides all 15 colors from the Shortcuts app:

- `red`, `orange`, `yellow`, `green`, `teal`, `blue`, `purple`, `pink`
- `darkOrange`, `lightBlue`, `darkBlue`, `lightPurple`
- `gray`, `greenGray`, `brown`

Each gradient adapts automatically to light and dark mode.
