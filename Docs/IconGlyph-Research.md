# IconGlyph Research

Investigating how Apple's `icon_glyph` Int64 values map to shortcut icons.

## Sample Data

| Shortcut | iconGlyph | Hex |
|----------|-----------|-----|
| Create Meeting Note | 59446 | 0xE836 |
| Start Pomodoro | 61512 | 0xF048 |
| Haiku | 61699 | 0xF103 |

## Key Findings

### 1. NOT Unicode/SF Symbols

Tested rendering these codepoints as Unicode characters with system fonts - **they don't render**. These are Apple's internal glyph IDs, not Unicode codepoints mapped to SF Symbols.

### 2. atnbueno/shortcut-icons Approach

The [atnbueno/shortcut-icons](https://github.com/atnbueno/shortcut-icons) repo works by:
- Extracting glyph images from somewhere (credited to @ActuallyTaylor)
- Arranging them in PNG sprite sheets (20x36 grid per iOS version)
- Creating CSS that maps each glyph ID to a sprite position
- **The mapping is manual** - glyph numbers don't mathematically calculate to positions

CSS structure:
```css
/* 20x36 grid */
background-size: 2000% 3600%;

/* Each glyph maps to x,y position */
.g59446::after { background-position-x: 73.6842% }
```

### 3. Apple's iCloud Web Rendering

When viewing shared shortcuts on icloud.com:
- Custom icons: Uses `icon.value.downloadURL` from the API
- Default glyphs: **Unknown** - the web JS must render them somehow

### 4. System Framework Locations

Searched macOS for glyph assets:

| Location | Contents |
|----------|----------|
| `/System/Applications/Shortcuts.app/Contents/Resources/Assets.car` | App icons only, no glyphs |
| `/System/Library/PrivateFrameworks/WorkflowUI.framework/Resources/Assets.car` | Has `ZZZZPackedAsset` entries, glyph references |
| `/System/Library/PrivateFrameworks/WorkflowKit.framework/Resources/Assets.car` | Named icons (AirDrop, Calculator, etc.) + `ZZZZPackedAsset` |

The `ZZZZPackedAsset-*.0.*-gamut0` entries appear to be packed glyph sprites.

### 5. Glyph Ranges by iOS Version

From atnbueno's sprite data:
- **iOS 12**: 59392-59870 (~250 glyphs)
- **iOS 14**: 61440-61531 (~90 new glyphs)
- **iOS 15**: 61532-61589 (~58 new glyphs)
- **iOS 18**: 61590-62212 (~200 new glyphs)
- **iOS 26**: 62213-62501 (~100 new glyphs)

### 6. Private API Discovery (BREAKTHROUGH)

Successfully found how to render glyphs using private APIs:

**Key Classes:**
| Class | Framework | Purpose |
|-------|-----------|---------|
| `WFWorkflowIcon` | WorkflowKit | Holds icon data (color, glyph, custom image) |
| `WFIcon` | WorkflowKit | Base icon class (abstract) |
| `WFSymbolIcon` | WorkflowKit | Subclass returned for glyph icons |
| `WFIconViewImageGenerator` | WorkflowUIServices | Renders icons to NSImage |

**WFWorkflowIcon Initializers:**
```objc
- initWithBackgroundColorValue:(uint64)glyphCharacter:(uint16)customImageData:(NSData*)
- initWithBackgroundColorValue:(uint64)glyphCharacter:(uint16)customImageData:(NSData*)symbolOverride:(NSString*)
- initWithPaletteColor:(WFColor*)glyphCharacter:(uint16)customImageData:(NSData*)
```

**WFWorkflowIcon Properties:**
- `backgroundColorValue` (UInt64) - RGBA color
- `glyphCharacter` (UInt16/struct) - The glyph ID
- `customImageData` (NSData) - Custom icon image data
- `icon` (WFIcon) - Returns the actual WFIcon instance
- `symbolOverride` (NSString) - SF Symbol name override

**Rendering Flow:**
1. Create `WFWorkflowIcon` with glyph ID and background color
2. Get the `icon` property (returns `WFSymbolIcon`)
3. Call `WFIconViewImageGenerator.loadIcon:size:style:` with the WFIcon

**Method Signature:**
```
loadIcon:size:style:
Type encoding: @48@0:8@16{CGSize=dd}24q40
- Returns: NSImage (or nil)
- Param 1: WFIcon object
- Param 2: CGSize (width, height)
- Param 3: Int64 (style - 0 works)
```

**Working Script:**
See `Scripts/RenderGlyph.swift` - successfully renders any glyph to PNG.

### 7. Asset Extraction Attempt

Tried extracting from `WorkflowKit.framework/Resources/Assets.car`:
- `xcrun assetutil` creates BOM files, not extracted images
- Would need specialized tools like `acextract` or similar
- The `ZZZZPackedAsset` entries are small (148x184 etc) - possibly icon packs, not full glyph sprites

## Open Questions

1. How does Apple's web renderer display glyphs without custom icons?
   - Possibly server-side rendering or embedded sprite sheets
2. ~~Is there a private API to render glyphs by ID?~~ **ANSWERED: Yes, see section 6**
3. What do different "style" values for `loadIcon:size:style:` do?
4. Can we use this in a shipping app? (Private API concerns)

## Research Scripts

All scripts are in `Scripts/` directory:

| Script | Purpose |
|--------|---------|
| `ExtractGlyphs.swift` | Tests loading named assets from framework bundles |
| `InspectWFIcon.swift` | Introspects WFIcon class methods/properties using ObjC runtime |
| `FindIconSubclasses.swift` | Finds WFIcon subclasses and their initializers |
| `RenderGlyph.swift` | **Renders any glyph ID to PNG using private APIs** |

Usage:
```bash
# Render glyph 59446 (keyboard icon)
swift Scripts/RenderGlyph.swift 59446

# Output: /tmp/glyph-59446.png
```

## Resources

- [atnbueno/shortcut-icons](https://github.com/atnbueno/shortcut-icons) - CSS sprites for web
- [RoutineHub Glyph Search](https://routinehub.co/shortcut/8147/) - Search glyphs by name
- `@ActuallyTaylor` - Helped extract original hi-res glyph images for atnbueno repo
