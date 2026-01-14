# ``SwiftShortcuts``

Display Apple Shortcuts galleries in SwiftUI apps.

## Overview

SwiftShortcuts provides SwiftUI views for displaying Apple Shortcuts with their icons, names, and signature gradient backgrounds. Tiles fetch metadata automatically from iCloud share URLs and open shortcuts directly in the Shortcuts app when tapped.

```swift
// Automatic metadata fetching
ShortcutTile(url: "https://www.icloud.com/shortcuts/abc123")

// Manual configuration
ShortcutTile(name: "Morning Routine", systemImage: "sun.horizon.fill", url: "...")
    .foregroundStyle(ShortcutGradient.orange)

// Custom tap action
ShortcutTile(id: "abc123") { url in
    // Custom behavior
}
```

## Topics

### Essentials

- <doc:GettingStarted>
- ``ShortcutTile``
- ``ShortcutActionsView``

### Styling

- ``ShortcutTileStyle``
- ``ShortcutTileStyleConfiguration``
- ``DefaultShortcutTileStyle``
- ``CompactShortcutTileStyle``
- ``ShortcutActionsViewStyle``
- ``ShortcutActionsViewStyleConfiguration``
- ``DefaultShortcutActionsViewStyle``

### Gradients

- ``ShortcutGradient``
