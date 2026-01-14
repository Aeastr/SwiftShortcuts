<div align="center">
  <img width="128" height="128" src="/resources/icon/icon.png" alt="SwiftShortcuts Icon">
  <h1><b>SwiftShortcuts</b></h1>
  <p>
    Display Shortcuts in SwiftUI apps.
  </p>
</div>

<p align="center">
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-6.2+-F05138?logo=swift&logoColor=white" alt="Swift 6.2+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/iOS-16+-000000?logo=apple" alt="iOS 16+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/macOS-13+-000000?logo=apple" alt="macOS 13+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/tvOS-16+-000000?logo=apple" alt="tvOS 16+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/watchOS-9+-000000?logo=apple" alt="watchOS 9+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/visionOS-1+-000000?logo=apple" alt="visionOS 1+"></a>
</p>


## Features

- **ID-based tiles** - Provide a shortcut ID and metadata is fetched automatically
- **URL-based tiles** - Provide an iCloud share URL and metadata is fetched automatically
- **Manual tiles** - Specify name, icon, and gradient for full control
- **Custom tap actions** - Override default behavior with action closure
- **Press feedback** - Built-in scale/opacity animations via ButtonStyle
- **Actions view** - Display the workflow steps inside a shortcut
- **Multiple styles** - Flow visualization, list view, or create your own
- **15 gradients** - Apple Shortcuts color palette built-in
- **Tap to open** - Tiles open shortcuts directly in the Shortcuts app


## Requirements

- Swift 6.2+
- iOS 16+ / macOS 13+ / watchOS 9+ / tvOS 16+ / visionOS 1+


## Installation

```swift
dependencies: [
    .package(url: "https://github.com/aeastr/SwiftShortcuts.git", from: "1.0.0")
]
```

```swift
import SwiftShortcuts
```


## Usage

### ID-based

Provide a shortcut ID and the tile fetches all metadata automatically:

```swift
ShortcutTile(id: "f00836becd2845109809720d2a70e32f")
```

<div align="center">
  <img src="/Resources/examples/cards.png" alt="Tiles" width="600">
</div>

### URL-based

Provide an iCloud share URL and the tile fetches all metadata automatically:

```swift
ShortcutTile(url: "https://www.icloud.com/shortcuts/abc123")
```

### Manual

Specify details yourself, use `.foregroundStyle()` for the gradient:

```swift
ShortcutTile(name: "Morning Routine", systemImage: "sun.horizon.fill", url: "https://...")
    .foregroundStyle(ShortcutGradient.orange)
```

### Custom Tap Actions

Override the default tap behavior (opening in Shortcuts app):

```swift
ShortcutTile(id: "abc123") { url in
    showDetailView(for: url)
}
```

### Shortcut Actions (Experimental)

Display the workflow steps inside a shortcut:

```swift
ShortcutActionsView(url: "https://www.icloud.com/shortcuts/abc123")
```

<div align="center">
  <img src="/Resources/examples/actions-view.png" alt="Actions view" width="600">
</div>

> **Note:** Action name and icon mappings are incomplete. Some actions may display raw identifiers or generic icons. [Contributions welcome!](#action-mappings)

The default style shows a flow visualization with indentation for control flow (If/Otherwise/Repeat). Use the list style for a simpler numbered view:

```swift
ShortcutActionsView(url: "https://www.icloud.com/shortcuts/abc123")
    .shortcutActionsViewStyle(.list)
```

### Custom Actions Styles

Create your own style by conforming to `ShortcutActionsViewStyle`:

```swift
struct MyActionsStyle: ShortcutActionsViewStyle {
    func makeBody(configuration: ShortcutActionsViewStyleConfiguration) -> some View {
        VStack {
            Text(configuration.shortcutName)
                .font(.headline)

            ForEach(configuration.actions) { action in
                Label(action.displayName, systemImage: action.systemImage)
            }
        }
    }
}

// Usage
ShortcutActionsView(url: "...")
    .shortcutActionsViewStyle(MyActionsStyle())
```

The protocol provides default implementations for `makeHeader`, `makeNode`, `makeLoadingState`, and `makeEmptyState` that you can use as building blocks or override.


## Customization

### Tile Styles

Apply the compact style for list layouts:

```swift
VStack {
    ShortcutTile(name: "Quick Note", systemImage: "note.text", url: "...")
        .foregroundStyle(ShortcutGradient.blue)

    ShortcutTile(name: "Start Timer", systemImage: "timer", url: "...")
        .foregroundStyle(ShortcutGradient.green)
}
.shortcutTileStyle(.compact)
```

### Custom Tile Styles

Create your own styles by conforming to `ShortcutTileStyle`. Styles receive `isPressed` for custom press feedback:

```swift
struct MyTileStyle: ShortcutTileStyle {
    func makeBody(configuration: ShortcutTileStyleConfiguration) -> some View {
        VStack {
            if let icon = configuration.icon {
                icon
                    .resizable()
                    .frame(width: 60, height: 60)
            }
            Text(configuration.name)
                .font(.caption)
        }
        .padding()
        .background(configuration.gradient ?? ShortcutGradient.gray)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        // Custom press feedback
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .opacity(configuration.isPressed ? 0.8 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Usage
ShortcutTile(url: "...")
    .shortcutTileStyle(MyTileStyle())
```

### Loading Stagger

When displaying multiple tiles, each tile waits a random delay before fetching metadata to avoid overwhelming the API. Configure this with `.shortcutLoadingStagger()`:

```swift
// Faster loading with smaller stagger (0.01-0.05 seconds)
ShortcutTile(id: "abc123")
    .shortcutLoadingStagger(0.01...0.05)

// Disable staggering entirely for immediate loading
ShortcutTile(id: "abc123")
    .shortcutLoadingStagger(.disabled)

// Apply to multiple tiles
VStack {
    ShortcutTile(id: "abc123")
    ShortcutTile(id: "def456")
}
.shortcutLoadingStagger(0.1...0.3)
```

Default stagger range is `0.05...0.2` seconds.

### Gradients

```swift
ShortcutGradient.red
ShortcutGradient.orange
ShortcutGradient.yellow
ShortcutGradient.green
ShortcutGradient.teal
ShortcutGradient.blue
ShortcutGradient.purple
ShortcutGradient.pink
// + darkOrange, lightBlue, darkBlue, lightPurple, gray, greenGray, brown
```


## Overview

### ShortcutTile

Displays a shortcut as a tappable tile. Supports three data modes:

1. **ID-based**: Takes a shortcut ID directly and fetches metadata automatically.

2. **URL-based**: Extracts the shortcut ID from the iCloud URL and fetches metadata automatically.

3. **Manual**: Uses the provided name and icon directly. The gradient comes from SwiftUI's `.foregroundStyle()` environment value.

ID-based and URL-based tiles load asynchronously with configurable staggered requests (see [Loading Stagger](#loading-stagger)).

Tapping a tile opens the shortcut in the Shortcuts app via the `shortcuts://` URL scheme by default. Pass an action closure to override this behavior.

Built-in tile styles:
- `DefaultShortcutTileStyle` - 1.5 aspect ratio tile with centered icon and name
- `CompactShortcutTileStyle` - Horizontal row with icon, name, and material background

### ShortcutActionsView (Experimental)

Displays the workflow actions/steps inside a shortcut. Fetches the shortcut's plist data and parses the action list.

Built-in actions styles:
- `FlowShortcutActionsViewStyle` - Flow visualization with connectors and control flow indentation (default)
- `ListShortcutActionsViewStyle` - Simple numbered list

Apple Shortcuts has hundreds of actions - we can't map them all. Unknown actions fall back to parsing the identifier and showing a generic icon. See [Contributing](#action-mappings) to help expand coverage.


## How It Works

### Undocumented iCloud API

Shortcut metadata is fetched from Apple's undocumented CloudKit endpoint:

```
https://www.icloud.com/shortcuts/api/records/{shortcut-id}
```

The response contains:
- `name` - Shortcut display name
- `icon_color` - Internal color code (Int64)
- `icon_glyph` - SF Symbol glyph identifier
- `icon` - Custom icon image URL (if set)

See [Docs/iCloud-API.md](Docs/iCloud-API.md) for full response structure and color code mappings.

### Icon Glyphs

Apple stores shortcut icons as Int64 glyph IDs in the `icon_glyph` field. These map to SF Symbols:

| Glyph ID | SF Symbol |
|----------|-----------|
| 59446 | `keyboard.fill` |
| 61512 | `timer` |
| 61699 | `append.page.fill` |
| ... | ... |

We extracted 836 mappings from Apple's private frameworks. See [Docs/IconGlyph-Research.md](Docs/IconGlyph-Research.md) for details.

**How ShortcutTile uses glyphs:**

When you use the URL-based initializer, ShortcutTile fetches the glyph ID and resolves it to an SF Symbol. This is the primary icon source:

1. **Glyph mapping** → SF Symbol from `icon_glyph` (primary)
2. **API image** → Falls back to `icon` URL if glyph unmapped
3. **None** → Shows gradient only if neither available

For manual tiles, you provide the icon directly via `systemImage:` or `image:`.

**Regenerating mappings** (macOS only):
```bash
swift run dump-glyphs > Sources/SwiftShortcuts/Mappings/GlyphMappings.generated.swift
```

### Color Mapping

Apple stores shortcut colors as Int64 codes. These are mapped to SwiftUI gradients:

| Color Code | Gradient |
|------------|----------|
| 4282601983 | Red |
| 4271458815 | Orange |
| 4274264319 | Yellow |
| 4292093695 | Green |
| 431817727 | Teal |
| 463140863 | Blue |
| 2071128575 | Purple |
| 3980825855 | Pink |
| ... | ... |

Some colors have alternate codes. All are mapped to the same gradient.

### Adaptive Gradients

Each gradient has four color values:
- Light mode: top + bottom
- Dark mode: top + bottom

Colors are computed from Apple's original hex values and adapt automatically to the system appearance.

### URL Scheme

Tapping a tile constructs and opens:

```
shortcuts://open-shortcut?id={shortcut-id}
```

This launches the Shortcuts app directly to the shortcut.


## Contributing

Contributions welcome! Some easy ways to help:

### Action Mappings

Apple Shortcuts has hundreds of actions. We can't map them all ourselves! If you see an action displaying incorrectly:

1. **Wrong name?** Add it to [`ActionMappings.swift`](Sources/SwiftShortcuts/Mappings/ActionMappings.swift):
   ```swift
   "is.workflow.actions.myaction": ActionInfo("My Action", icon: "star"),
   ```

2. **Word not splitting?** Add it to [`CommonWords.swift`](Sources/SwiftShortcuts/Mappings/CommonWords.swift):
   ```swift
   "myword",
   ```

3. **Missing icon pattern?** Add a fallback in [`WorkflowAction.swift`](Sources/SwiftShortcuts/Models/WorkflowAction.swift):
   ```swift
   if identifier.contains("myword") { return "star" }
   ```

### Glyph Mappings

If you notice a shortcut icon not rendering correctly, the glyph ID might be missing from our mappings. On macOS, you can regenerate:

```bash
swift run dump-glyphs > Sources/SwiftShortcuts/Mappings/GlyphMappings.generated.swift
```

### New Features

Have an idea? Open an issue or submit a PR.


## License

MIT. See [LICENSE](LICENSE) for details.
