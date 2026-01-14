//
//  GlyphMappingsTests.swift
//  SwiftShortcuts
//

import Testing
@testable import SwiftShortcuts

@Suite("GlyphMappings")
struct GlyphMappingsTests {

    @Test("Returns symbol for known glyph ID")
    func knownGlyph() {
        // keyboard.fill = 59446
        let symbol = GlyphMappings.symbol(for: 59446)
        #expect(symbol == "keyboard.fill")
    }

    @Test("Returns nil for unknown glyph ID")
    func unknownGlyph() {
        let symbol = GlyphMappings.symbol(for: 99999)
        #expect(symbol == nil)
    }

    @Test("Returns fallback for unknown glyph when using default parameter")
    func fallbackForUnknown() {
        let symbol = GlyphMappings.symbol(for: 99999, default: "questionmark")
        #expect(symbol == "questionmark")
    }

    @Test("Returns mapped symbol over fallback when glyph is known")
    func mappedOverFallback() {
        let symbol = GlyphMappings.symbol(for: 59446, default: "fallback")
        #expect(symbol == "keyboard.fill")
    }

    @Test("Sample of known glyph mappings")
    func verifyKnownMappings() {
        // Values from GlyphMappings.generated.swift
        let knownMappings: [(Int64, String)] = [
            (59392, "ellipsis"),
            (59399, "house.fill"),
            (59401, "camera.fill"),
            (59409, "envelope.fill"),
            (59410, "bolt.fill"),
            (59412, "globe"),
            (59415, "clock.fill"),
            (59416, "location.fill"),
            (59417, "star.fill"),
            (59418, "moon.fill"),
            (59442, "trash.fill"),
            (59446, "keyboard.fill"),
            (59474, "folder.fill"),
            (59475, "pencil"),
            (59481, "heart.fill"),
            (59492, "lock.fill"),
            (59499, "gear"),
            (59501, "mic.fill"),
            (59508, "play.fill"),
            (59529, "link"),
            (59700, "plus"),
            (61503, "music.note"),
        ]

        for (glyphID, expectedSymbol) in knownMappings {
            let symbol = GlyphMappings.symbol(for: glyphID)
            #expect(symbol == expectedSymbol, "Glyph \(glyphID) should map to \(expectedSymbol)")
        }
    }
}
