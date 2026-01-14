# Color Extensions

## Overview

This file provides color mapping for Apple Shortcuts icons. The Shortcuts API returns an `iconColor` value (an `Int64` identifier) for each shortcut, but these values don't directly correspond to usable colors—they're opaque identifiers that Apple uses internally.

## The Problem

When you query a shortcut's metadata via the Shortcuts API, you receive an `iconColor` field containing a large integer like `4282601983` or `463140863`. These numbers are **color identifiers**, not actual color values (like hex or RGB).

Apple doesn't provide documentation for mapping these identifiers to their corresponding colors. Without a manual mapping, you'd have no way to accurately reproduce the shortcut's icon color in your UI.

## The Solution

`ShortcutColors.colorMap` provides a manually-curated mapping from these color identifiers to their actual gradient colors. Each shortcut icon uses a vertical gradient with four color variants:

| Variant | Usage |
|---------|-------|
| `lightTop` | Top of gradient in light mode |
| `lightBottom` | Bottom of gradient in light mode |
| `darkTop` | Top of gradient in dark mode |
| `darkBottom` | Bottom of gradient in dark mode |

## Color Identifier Table

| Color | Identifier(s) |
|-------|---------------|
| Red | `4282601983`, `12365313` |
| Dark Orange | `43634177`, `4251333119` |
| Orange | `4271458815`, `23508481` |
| Yellow | `4274264319`, `20702977` |
| Green | `4292093695`, `2873601` |
| Teal | `431817727` |
| Light Blue | `1440408063` |
| Blue | `463140863` |
| Dark Blue | `946986751` |
| Purple | `2071128575` |
| Light Purple | `3679049983`, `61591313` |
| Pink | `314141441`, `3980825855` |
| Gray | `255`, `1263359489` |
| Green-Gray | `3031607807` |
| Brown | `1448498689`, `2846468607` |

> Some colors have alternate identifiers that map to the same gradient.

## Usage

### Automatic (from API data)

When you have a shortcut's `iconColor` from the API:

```swift
let gradient = ShortcutColors.gradient(for: shortcut.iconColor)

RoundedRectangle(cornerRadius: 8)
    .fill(gradient)
```

### Manual (with ShortcutGradient)

For custom UI where you want to use Shortcuts-style colors directly:

```swift
ShortcutTile(name: "My Shortcut", systemImage: "star", url: "...")
    .foregroundStyle(ShortcutGradient.blue)
```

Available gradients:
- `ShortcutGradient.red`
- `ShortcutGradient.darkOrange`
- `ShortcutGradient.orange`
- `ShortcutGradient.yellow`
- `ShortcutGradient.green`
- `ShortcutGradient.teal`
- `ShortcutGradient.lightBlue`
- `ShortcutGradient.blue`
- `ShortcutGradient.darkBlue`
- `ShortcutGradient.purple`
- `ShortcutGradient.lightPurple`
- `ShortcutGradient.pink`
- `ShortcutGradient.gray`
- `ShortcutGradient.greenGray`
- `ShortcutGradient.brown`

## Adding New Colors

If you encounter a shortcut with an unmapped color identifier:

1. Note the `iconColor` value from the API
2. Visually identify the color from the Shortcuts app
3. Use a color picker to extract the gradient colors (top and bottom, in both light and dark mode)
4. Add the mapping to `ShortcutColors.colorMap`
