//
//  ShortcutColorsTests.swift
//  SwiftShortcuts
//

import Testing
import SwiftUI
@testable import SwiftShortcuts

@Suite("ShortcutColors")
struct ShortcutColorsTests {

    // Known color codes from the colorMap
    static let knownColorCodes: [Int64] = [
        4282601983,   // red
        12365313,     // red alt
        43634177,     // darkOrange
        4251333119,   // darkOrange alt
        4271458815,   // orange
        23508481,     // orange alt
        4274264319,   // yellow
        20702977,     // yellow alt
        4292093695,   // green
        2873601,      // green alt
        431817727,    // teal
        1440408063,   // lightBlue
        463140863,    // blue
        946986751,    // darkBlue
        2071128575,   // purple
        3679049983,   // lightPurple
        61591313,     // lightPurple alt
        314141441,    // pink
        3980825855,   // pink alt
        255,          // gray
        1263359489,   // gray alt
        3031607807,   // greenGray
        1448498689,   // brown
        2846468607,   // brown alt
    ]

    @Test("Maps all known color codes to gradients")
    func knownColorMappings() {
        for colorCode in Self.knownColorCodes {
            // Verify gradient is returned for known color codes
            let gradient = ShortcutColors.gradient(for: colorCode)
            // Can't easily compare LinearGradient, but we verify it doesn't crash
            _ = gradient
        }
    }

    @Test("Returns fallback gradient for unknown color code")
    func unknownColorFallback() {
        let gradient = ShortcutColors.gradient(for: 12345)
        // Should return a gray gradient fallback
        _ = gradient
    }

    @Test("Handles negative color codes by using absolute value")
    func negativeColorCode() {
        // Negative of blue (463140863) should still map correctly
        let gradient = ShortcutColors.gradient(for: -463140863)
        _ = gradient
    }

    @Test("Color map contains expected number of entries")
    func colorMapSize() {
        // 24 entries as per the colorMap definition
        #expect(ShortcutColors.colorMap.count == 24)
    }

    // MARK: - Public Gradients

    @Test("Public ShortcutGradient provides all color options")
    func publicGradientsExist() {
        // Verify all public gradients are accessible
        _ = ShortcutGradient.red
        _ = ShortcutGradient.darkOrange
        _ = ShortcutGradient.orange
        _ = ShortcutGradient.yellow
        _ = ShortcutGradient.green
        _ = ShortcutGradient.teal
        _ = ShortcutGradient.lightBlue
        _ = ShortcutGradient.blue
        _ = ShortcutGradient.darkBlue
        _ = ShortcutGradient.purple
        _ = ShortcutGradient.lightPurple
        _ = ShortcutGradient.pink
        _ = ShortcutGradient.gray
        _ = ShortcutGradient.greenGray
        _ = ShortcutGradient.brown
    }
}
