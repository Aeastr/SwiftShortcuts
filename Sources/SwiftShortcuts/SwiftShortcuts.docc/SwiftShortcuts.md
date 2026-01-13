# ``SwiftShortcuts``

Display Apple Shortcuts galleries in SwiftUI apps.

## Overview

SwiftShortcuts provides SwiftUI views for displaying Apple Shortcuts with their icons, names, and signature gradient backgrounds. Cards fetch metadata automatically from iCloud share URLs and open shortcuts directly in the Shortcuts app when tapped.

```swift
// Automatic metadata fetching
ShortcutCard(url: "https://www.icloud.com/shortcuts/abc123")

// Manual configuration
ShortcutCard(name: "Morning Routine", systemImage: "sun.horizon.fill", url: "...")
    .foregroundStyle(ShortcutGradient.orange)
```

## Topics

### Essentials

- <doc:GettingStarted>
- ``ShortcutCard``
- ``ShortcutActionsView``

### Styling

- ``ShortcutCardStyle``
- ``ShortcutCardStyleConfiguration``
- ``DefaultShortcutCardStyle``
- ``CompactShortcutCardStyle``
- ``ShortcutActionsViewStyle``
- ``ShortcutActionsViewStyleConfiguration``
- ``DefaultShortcutActionsViewStyle``

### Gradients

- ``ShortcutGradient``
