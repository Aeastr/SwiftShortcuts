# IconGlyph Research

Investigating how Apple's `icon_glyph` Int64 values map to SF Symbols.

## Sample Data

| Shortcut | iconGlyph | Hex | Notes |
|----------|-----------|-----|-------|
| Create Meeting Note | 59446 | 0xE836 | |
| Start Pomodoro | 61512 | 0xF048 | |
| Haiku | 61699 | 0xF103 | |

## Analysis

These values are in the Unicode Private Use Area (PUA) range:
- Private Use Area: U+E000 to U+F8FF

SF Symbols uses this range for its glyphs. The glyph values appear to be direct Unicode codepoints.

## Approach Options

1. **Direct Unicode rendering** - Try rendering the codepoint with SF Symbols font
2. **Lookup table** - Build a mapping from known glyph codes to SF Symbol names
3. **Reverse engineer** - Find Apple's internal mapping

## Testing

TODO: Test if these codepoints render directly with SF Symbols font.
