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

### Manual

Specify details yourself, use `.foregroundStyle()` for the gradient:

```swift
ShortcutCard(name: "Morning Routine", systemImage: "sun.horizon.fill", url: "https://...")
    .foregroundStyle(ShortcutGradient.orange)
```

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


## How It Works

`ShortcutCard` supports two data modes:

1. **URL-based**: Extracts the shortcut ID from the iCloud URL and fetches metadata from Apple's CloudKit API. Icon images are loaded asynchronously with staggered requests to avoid rate limiting.

2. **Manual**: Uses the provided name and icon directly. The gradient comes from SwiftUI's `.foregroundStyle()` environment value.

Tapping a card constructs a `shortcuts://open-shortcut?id=...` URL and opens it via the system.

The style system uses a `ShortcutCardStyle` protocol. Built-in styles:
- `DefaultShortcutCardStyle` - 1.5 aspect ratio card with centered icon and name
- `CompactShortcutCardStyle` - Horizontal row with icon, name, and material background


## Contributing

Contributions welcome. Please feel free to submit a Pull Request.


## License

MIT. See [LICENSE](LICENSE) for details.
