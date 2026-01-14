# CLI Tool (sstools)

The package includes `sstools`, a CLI tool for fetching shortcut data and generating code.

## Installation

Run directly from the package:

```bash
swift run sstools --help
```

Or build and install globally:

```bash
swift build -c release
cp .build/release/sstools /usr/local/bin/
```

## Commands

### fetch

Fetch shortcut metadata from iCloud and output as JSON or Swift code.

```bash
sstools fetch [<shortcuts> ...] [options]
```

**Arguments:**
- `<shortcuts>` - One or more shortcut URLs or IDs

**Options:**
- `-f, --file <file>` - File containing URLs/IDs (one per line)
- `-o, --output <path>` - Output file path (prints to stdout if not specified)
- `-p, --pretty` - Pretty print JSON output
- `-a, --actions` - Include workflow actions in output
- `--swift` - Output as Swift code instead of JSON
- `--array-name <name>` - Array name for Swift output (default: `shortcuts`)

#### Examples

**Single shortcut:**
```bash
sstools fetch abc123 -o shortcut.json
```

**Multiple shortcuts:**
```bash
sstools fetch abc123 def456 ghi789 -o shortcuts.json
```

**From a file:**
```bash
sstools fetch --file links.txt -o shortcuts.json
```

The file format is one URL or ID per line. Lines starting with `#` are treated as comments:

```
# My shortcuts
https://www.icloud.com/shortcuts/abc123
def456
https://www.icloud.com/shortcuts/ghi789
```

**With workflow actions:**
```bash
sstools fetch abc123 --actions -o shortcut.json
```

**Generate Swift code:**
```bash
sstools fetch abc123 def456 --swift -o Shortcuts.swift
```

**Custom array name:**
```bash
sstools fetch --file links.txt --swift --array-name myShortcuts -o MyShortcuts.swift
```

#### Output Formats

**JSON** (default):
```json
{
  "id": "abc123",
  "name": "My Shortcut",
  "icon_color": 4282601983,
  "icon_glyph": 59771,
  "icon_url": "https://...",
  "shortcut_url": "https://...",
  "i_cloud_link": "https://www.icloud.com/shortcuts/abc123"
}
```

Multiple shortcuts output as a JSON array.

**Swift** (`--swift`):
```swift
import SwiftShortcuts

let shortcuts: [ShortcutData] = [
    ShortcutData(
        id: "abc123",
        name: "My Shortcut",
        iconColor: 4282601983,
        iconGlyph: 59771,
        iconURL: "https://...",
        shortcutURL: "https://...",
        iCloudLink: "https://www.icloud.com/shortcuts/abc123"
    ),
]
```

### dump-glyphs

Extract SF Symbol mappings from macOS Shortcuts frameworks. **macOS only.**

```bash
sstools dump-glyphs [options]
```

**Options:**
- `-s, --range-start <n>` - Start of glyph range (default: 59392)
- `-e, --range-end <n>` - End of glyph range (default: 62501)

#### Example

Regenerate the glyph mappings file:

```bash
sstools dump-glyphs > Sources/SwiftShortcuts/Mappings/GlyphMappings.generated.swift
```

## Loading Fetched Data

Use the JSON output with `ShortcutData.load()`:

```swift
// From bundle resource
let shortcuts = try ShortcutData.load(resource: "my-shortcuts")

// From file URL
let shortcuts = try ShortcutData.load(contentsOf: url)

// From raw data
let shortcuts = try ShortcutData.load(from: jsonData)
```

All methods return `[ShortcutData]` and auto-detect single object vs array format.

Or use `--swift` output to embed data directly in your app with no runtime parsing.
