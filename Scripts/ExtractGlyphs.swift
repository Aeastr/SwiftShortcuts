#!/usr/bin/env swift
//
//  ExtractGlyphs.swift
//  SwiftShortcuts
//
//  Research script for extracting shortcut icon glyphs from system frameworks.
//  Run with: swift Scripts/ExtractGlyphs.swift
//

import Foundation
import AppKit

print("=== Glyph Extraction Research ===\n")

// MARK: - Framework Paths

let frameworks = [
    "/System/Library/PrivateFrameworks/WorkflowKit.framework",
    "/System/Library/PrivateFrameworks/WorkflowUI.framework",
    "/System/Library/PrivateFrameworks/WorkflowUICore.framework",
]

// MARK: - Test Loading Named Assets

func testNamedAssets(bundle: Bundle, names: [String]) {
    print("Testing named assets in \(bundle.bundlePath.components(separatedBy: "/").last ?? ""):")
    for name in names {
        if let image = bundle.image(forResource: name) {
            print("  ✓ \(name): \(image.size)")
        } else {
            print("  ✗ \(name)")
        }
    }
    print()
}

// MARK: - Known Asset Names

let knownNames = [
    // From WorkflowKit
    "Shortcuts", "AirDrop", "Calculator", "Health", "Photos", "Siri",
    // From WorkflowUI
    "AppleIntelligence", "Placeholder", "ShortcutStack2", "Sphiri",
    // Glyph attempts
    "59446", "g59446", "glyph59446", "icon59446",
    // Packed assets
    "ZZZZPackedAsset-1.0.0-gamut0",
]

// MARK: - Main

for path in frameworks {
    if let bundle = Bundle(path: path) {
        testNamedAssets(bundle: bundle, names: knownNames)
    } else {
        print("Failed to load: \(path)\n")
    }
}

// MARK: - Try to extract an image and save it

print("=== Attempting to save an image ===\n")

if let bundle = Bundle(path: "/System/Library/PrivateFrameworks/WorkflowKit.framework"),
   let image = bundle.image(forResource: "Shortcuts") {

    let outputPath = "/tmp/shortcuts-icon.png"

    if let tiffData = image.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiffData),
       let pngData = bitmap.representation(using: .png, properties: [:]) {
        do {
            try pngData.write(to: URL(fileURLWithPath: outputPath))
            print("✓ Saved to \(outputPath)")
        } catch {
            print("✗ Failed to save: \(error)")
        }
    }
}

print("\n=== Research Notes ===")
print("""
- Named assets like 'Shortcuts', 'AirDrop' work via bundle.image(forResource:)
- Glyph numbers (59446 etc.) don't work as asset names
- ZZZZPackedAsset entries don't load via image(forResource:)
- The 700+ glyphs must be stored/accessed differently
- Possible: private API, different naming scheme, or separate sprite sheet
""")
