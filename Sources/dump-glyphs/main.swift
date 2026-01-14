//
//  dump-glyphs
//  SwiftShortcuts
//
//  CLI tool to extract glyph ID → SF Symbol mappings from macOS Shortcuts frameworks.
//
//  Usage:
//    swift run dump-glyphs > Sources/SwiftShortcuts/Internal/GlyphMappings.generated.swift
//

import Foundation
import AppKit

// MARK: - Configuration

let glyphRange: ClosedRange<UInt16> = 59392...62501

// MARK: - Load Frameworks

guard Bundle(path: "/System/Library/PrivateFrameworks/WorkflowKit.framework")?.load() == true else {
    fputs("Error: Failed to load WorkflowKit.framework\n", stderr)
    fputs("This tool requires macOS with Shortcuts.app installed.\n", stderr)
    exit(1)
}

Bundle(path: "/System/Library/PrivateFrameworks/WorkflowUIServices.framework")?.load()

// MARK: - Get Classes

guard let workflowIconClass: AnyClass = NSClassFromString("WFWorkflowIcon") else {
    fputs("Error: WFWorkflowIcon class not found\n", stderr)
    exit(1)
}

// MARK: - Setup Method Calls

typealias InitMethod = @convention(c) (AnyObject, Selector, UInt64, UInt16, NSData?) -> AnyObject?

let allocSel = NSSelectorFromString("alloc")
let initSel = NSSelectorFromString("initWithBackgroundColorValue:glyphCharacter:customImageData:")
let iconSel = NSSelectorFromString("icon")
let symbolNameSel = NSSelectorFromString("symbolName")

guard let initMethod = class_getInstanceMethod(workflowIconClass, initSel) else {
    fputs("Error: Could not get init method\n", stderr)
    exit(1)
}

let initFunc = unsafeBitCast(method_getImplementation(initMethod), to: InitMethod.self)

// MARK: - Extract Mappings

fputs("Extracting glyph mappings (\(glyphRange.lowerBound)-\(glyphRange.upperBound))...\n", stderr)

var mappings: [(UInt16, String)] = []

for glyphID in glyphRange {
    autoreleasepool {
        guard let allocated = (workflowIconClass as AnyObject).perform(allocSel)?.takeUnretainedValue(),
              let icon = initFunc(allocated, initSel, 0x000000FF, glyphID, nil) as? NSObject,
              icon.responds(to: iconSel),
              let wfIcon = icon.perform(iconSel)?.takeUnretainedValue() as? NSObject,
              wfIcon.responds(to: symbolNameSel),
              let name = wfIcon.perform(symbolNameSel)?.takeUnretainedValue() as? String else {
            return
        }
        mappings.append((glyphID, name))
    }
}

fputs("Found \(mappings.count) mappings\n", stderr)

// MARK: - Output

print("""
//
//  GlyphMappings.generated.swift
//  SwiftShortcuts
//
//  Auto-generated glyph ID → SF Symbol mappings.
//  Generated: \(ISO8601DateFormatter().string(from: Date()))
//
//  Regenerate: swift run dump-glyphs > Sources/SwiftShortcuts/Internal/GlyphMappings.generated.swift
//

// swiftlint:disable file_length

extension GlyphMappings {
    static let mappings: [UInt16: String] = [
""")

for (id, name) in mappings {
    print("        \(id): \"\(name)\",")
}

print("""
    ]
}

// swiftlint:enable file_length
""")
