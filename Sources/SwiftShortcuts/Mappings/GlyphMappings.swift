//
//  GlyphMappings.swift
//  SwiftShortcuts
//
//  Maps shortcut icon glyph IDs to SF Symbol names.
//

import Foundation

/// Maps shortcut icon glyph IDs (from `icon_glyph` field) to SF Symbol names.
///
/// Usage:
/// ```swift
/// if let symbolName = GlyphMappings.symbol(for: 59446) {
///     Image(systemName: symbolName) // keyboard.fill
/// }
/// ```
enum GlyphMappings {
    /// Returns the SF Symbol name for a glyph ID, or nil if unknown.
    static func symbol(for glyphID: Int64) -> String? {
        guard glyphID >= 0, glyphID <= Int64(UInt16.max) else { return nil }
        return mappings[UInt16(glyphID)]
    }

    /// Returns the SF Symbol name for a glyph ID, or a fallback symbol.
    static func symbol(for glyphID: Int64, default fallback: String) -> String {
        guard glyphID >= 0, glyphID <= Int64(UInt16.max) else { return fallback }
        return mappings[UInt16(glyphID)] ?? fallback
    }
}
