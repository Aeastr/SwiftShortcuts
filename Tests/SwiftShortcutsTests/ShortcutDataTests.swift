//
//  ShortcutDataTests.swift
//  SwiftShortcuts
//

import Testing
import Foundation
@testable import SwiftShortcuts

@Suite("ShortcutData")
struct ShortcutDataTests {

    // MARK: - JSON Decoding

    @Test("Decodes single shortcut from JSON")
    func decodeSingleShortcut() throws {
        let json = """
        {
            "id": "ABC123",
            "name": "Test Shortcut",
            "icon_color": 463140863,
            "icon_glyph": 59446,
            "icon_url": "https://example.com/icon.png",
            "shortcut_url": "https://example.com/shortcut.plist",
            "i_cloud_link": "https://www.icloud.com/shortcuts/ABC123"
        }
        """

        let data = try #require(json.data(using: .utf8))
        let shortcuts = try ShortcutData.load(from: data)

        #expect(shortcuts.count == 1)
        let shortcut = shortcuts[0]
        #expect(shortcut.id == "ABC123")
        #expect(shortcut.name == "Test Shortcut")
        #expect(shortcut.iconColor == 463140863)
        #expect(shortcut.iconGlyph == 59446)
        #expect(shortcut.iconURL == "https://example.com/icon.png")
        #expect(shortcut.shortcutURL == "https://example.com/shortcut.plist")
        #expect(shortcut.iCloudLink == "https://www.icloud.com/shortcuts/ABC123")
        #expect(shortcut.image == nil)
    }

    @Test("Decodes array of shortcuts from JSON")
    func decodeMultipleShortcuts() throws {
        let json = """
        [
            {
                "id": "ABC123",
                "name": "First Shortcut",
                "icon_color": 463140863,
                "icon_glyph": 59446,
                "i_cloud_link": "https://www.icloud.com/shortcuts/ABC123"
            },
            {
                "id": "DEF456",
                "name": "Second Shortcut",
                "icon_color": 4282601983,
                "icon_glyph": 61440,
                "i_cloud_link": "https://www.icloud.com/shortcuts/DEF456"
            }
        ]
        """

        let data = try #require(json.data(using: .utf8))
        let shortcuts = try ShortcutData.load(from: data)

        #expect(shortcuts.count == 2)
        #expect(shortcuts[0].id == "ABC123")
        #expect(shortcuts[0].name == "First Shortcut")
        #expect(shortcuts[1].id == "DEF456")
        #expect(shortcuts[1].name == "Second Shortcut")
    }

    @Test("Handles optional fields correctly")
    func decodeWithOptionalFields() throws {
        let json = """
        {
            "id": "ABC123",
            "name": "Minimal Shortcut",
            "icon_color": 463140863,
            "icon_glyph": 59446,
            "i_cloud_link": "https://www.icloud.com/shortcuts/ABC123"
        }
        """

        let data = try #require(json.data(using: .utf8))
        let shortcuts = try ShortcutData.load(from: data)

        #expect(shortcuts.count == 1)
        #expect(shortcuts[0].iconURL == nil)
        #expect(shortcuts[0].shortcutURL == nil)
    }

    // MARK: - JSON Encoding

    @Test("Round-trips through JSON encoding/decoding")
    func roundTripEncoding() throws {
        let original = ShortcutData(
            id: "TEST123",
            name: "Round Trip Test",
            iconColor: 463140863,
            iconGlyph: 59446,
            iconURL: "https://example.com/icon.png",
            shortcutURL: "https://example.com/shortcut.plist",
            iCloudLink: "https://www.icloud.com/shortcuts/TEST123"
        )

        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ShortcutData.self, from: encoded)

        #expect(decoded.id == original.id)
        #expect(decoded.name == original.name)
        #expect(decoded.iconColor == original.iconColor)
        #expect(decoded.iconGlyph == original.iconGlyph)
        #expect(decoded.iconURL == original.iconURL)
        #expect(decoded.shortcutURL == original.shortcutURL)
        #expect(decoded.iCloudLink == original.iCloudLink)
    }

    // MARK: - Computed Properties

    @Test("Provides gradient based on iconColor")
    func gradientComputed() {
        let shortcut = ShortcutData(
            id: "TEST",
            name: "Test",
            iconColor: 463140863, // Blue
            iconGlyph: 59446,
            iconURL: nil,
            shortcutURL: nil,
            iCloudLink: "https://www.icloud.com/shortcuts/TEST"
        )

        // Just verify gradient is returned (can't easily compare LinearGradient)
        _ = shortcut.gradient
    }

    @Test("Provides icon symbol from glyph mapping")
    func iconFromGlyph() {
        let shortcut = ShortcutData(
            id: "TEST",
            name: "Test",
            iconColor: 463140863,
            iconGlyph: 59446, // keyboard.fill
            iconURL: nil,
            shortcutURL: nil,
            iCloudLink: "https://www.icloud.com/shortcuts/TEST"
        )

        #expect(shortcut.icon == "keyboard.fill")
    }

    @Test("Returns nil for unmapped glyph")
    func unmappedGlyph() {
        let shortcut = ShortcutData(
            id: "TEST",
            name: "Test",
            iconColor: 463140863,
            iconGlyph: 99999, // Unmapped
            iconURL: nil,
            shortcutURL: nil,
            iCloudLink: "https://www.icloud.com/shortcuts/TEST"
        )

        #expect(shortcut.icon == nil)
    }

    // MARK: - with(image:)

    @Test("Creates copy with image using with(image:)")
    func withImage() {
        let original = ShortcutData(
            id: "TEST",
            name: "Test",
            iconColor: 463140863,
            iconGlyph: 59446,
            iconURL: nil,
            shortcutURL: nil,
            iCloudLink: "https://www.icloud.com/shortcuts/TEST"
        )

        #expect(original.image == nil)

        // Note: Can't easily create a test Image, but we can verify the method exists
        let withNilImage = original.with(image: nil)
        #expect(withNilImage.id == original.id)
        #expect(withNilImage.name == original.name)
    }
}
