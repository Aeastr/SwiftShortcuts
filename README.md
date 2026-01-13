<div align="center">
  <img width="128" height="128" src="/Resources/icon/icon.png" alt="SwiftShortcuts Icon">
  <h1><b>SwiftShortcuts</b></h1>
  <p>
    Display Apple Shortcuts galleries in SwiftUI apps.
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

- **URL-based cards** - Provide an iCloud share URL and metadata is fetched automatically
- **Manual cards** - Specify name, icon, and gradient for full control
- **Two styles** - Default card layout or compact list style
- **15 gradients** - Apple Shortcuts color palette built-in
- **Tap to open** - Cards open shortcuts directly in the Shortcuts app


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

### URL-based

Provide an iCloud share URL and the card fetches all metadata automatically:

```swift
ShortcutCard(url: "https://www.icloud.com/shortcuts/abc123")
```

<div align="center">
  <img src="/Resources/examples/url-based.png" alt="URL-based cards" width="600">
</div>

### Manual

Specify details yourself, use `.foregroundStyle()` for the gradient:

```swift
ShortcutCard(name: "Morning Routine", systemImage: "sun.horizon.fill", url: "https://...")
    .foregroundStyle(ShortcutGradient.orange)
```

<div align="center">
  <img src="/Resources/examples/manual.png" alt="Manual cards" width="600">
</div>

### Styling

Apply the compact style for list layouts:

```swift
VStack {
    ShortcutCard(name: "Quick Note", systemImage: "note.text", url: "...")
        .foregroundStyle(ShortcutGradient.blue)

    ShortcutCard(name: "Start Timer", systemImage: "timer", url: "...")
        .foregroundStyle(ShortcutGradient.green)
}
.shortcutCardStyle(.compact)
```

<div align="center">
  <img src="/Resources/examples/styling.png" alt="Compact style" width="600">
</div>

### Custom Styles

Create your own styles by conforming to `ShortcutCardStyle`:

```swift
struct MyCardStyle: ShortcutCardStyle {
    func makeBody(configuration: ShortcutCardStyleConfiguration) -> some View {
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
    }
}

// Usage
ShortcutCard(url: "...")
    .shortcutCardStyle(MyCardStyle())
```

### Available Gradients

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

`ShortcutCard` supports two data modes:

1. **URL-based**: Extracts the shortcut ID from the iCloud URL and fetches metadata automatically. Icons load asynchronously with staggered requests to avoid rate limiting.

2. **Manual**: Uses the provided name and icon directly. The gradient comes from SwiftUI's `.foregroundStyle()` environment value.

Tapping a card opens the shortcut in the Shortcuts app via the `shortcuts://` URL scheme.

Built-in styles:
- `DefaultShortcutCardStyle` - 1.5 aspect ratio card with centered icon and name
- `CompactShortcutCardStyle` - Horizontal row with icon, name, and material background


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

Tapping a card constructs and opens:

```
shortcuts://open-shortcut?id={shortcut-id}
```

This launches the Shortcuts app directly to the shortcut.


## Contributing

Contributions welcome! Some easy ways to help:

### Action Mappings

Apple Shortcuts has hundreds of actions. We can't map them all ourselves! If you see an action displaying incorrectly:

1. **Wrong name?** Add it to [`ActionMappings.swift`](Sources/SwiftShortcuts/Internal/ActionMappings.swift):
   ```swift
   "is.workflow.actions.myaction": ActionInfo("My Action", icon: "star"),
   ```

2. **Word not splitting?** Add it to [`CommonWords.swift`](Sources/SwiftShortcuts/Internal/CommonWords.swift):
   ```swift
   "myword",
   ```

3. **Missing icon pattern?** Add a fallback in [`WorkflowAction.swift`](Sources/SwiftShortcuts/Internal/WorkflowAction.swift):
   ```swift
   if identifier.contains("myword") { return "star" }
   ```

### New Features

Have an idea? Open an issue or submit a PR.


## License

MIT. See [LICENSE](LICENSE) for details.
