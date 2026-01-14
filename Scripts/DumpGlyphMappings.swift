#!/usr/bin/env swift
//
//  DumpGlyphMappings.swift
//  SwiftShortcuts
//
//  Dumps all glyph ID → SF Symbol name mappings.
//  Run with: swift Scripts/DumpGlyphMappings.swift
//
//  Output can be piped to a file:
//  swift Scripts/DumpGlyphMappings.swift > Sources/SwiftShortcuts/Internal/GlyphMappings.generated.swift
//

import Foundation
import AppKit
import ObjectiveC

// Full range covering iOS 12 through iOS 26
let startID: UInt16 = 59392
let endID: UInt16 = 62501

// Load frameworks
Bundle(path: "/System/Library/PrivateFrameworks/WorkflowKit.framework")?.load()
Bundle(path: "/System/Library/PrivateFrameworks/WorkflowUIServices.framework")?.load()

// Get classes
guard let workflowIconClass: AnyClass = NSClassFromString("WFWorkflowIcon") else {
    fputs("// ERROR: Failed to load WorkflowKit framework\n", stderr)
    exit(1)
}

typealias InitMethodType = @convention(c) (AnyObject, Selector, UInt64, UInt16, NSData?) -> AnyObject?

let allocSel = NSSelectorFromString("alloc")
let initSel = NSSelectorFromString("initWithBackgroundColorValue:glyphCharacter:customImageData:")
let iconSel = NSSelectorFromString("icon")
let symbolNameSel = NSSelectorFromString("symbolName")

guard let initMethod = class_getInstanceMethod(workflowIconClass, initSel) else {
    fputs("// ERROR: Failed to get init method\n", stderr)
    exit(1)
}

let initFunc = unsafeBitCast(method_getImplementation(initMethod), to: InitMethodType.self)

// Collect mappings
fputs("Extracting glyph mappings (\(startID)-\(endID))...\n", stderr)

var mappings: [(UInt16, String)] = []

for glyphID in startID...endID {
    autoreleasepool {
        guard let allocated = (workflowIconClass as AnyObject).perform(allocSel)?.takeUnretainedValue(),
              let workflowIcon = initFunc(allocated, initSel, 0x000000FF, glyphID, nil) as? NSObject,
              workflowIcon.responds(to: iconSel),
              let wfIcon = workflowIcon.perform(iconSel)?.takeUnretainedValue() as? NSObject,
              wfIcon.responds(to: symbolNameSel),
              let symbolName = wfIcon.perform(symbolNameSel)?.takeUnretainedValue() as? String else {
            return
        }
        mappings.append((glyphID, symbolName))
    }
}

fputs("Found \(mappings.count) mappings\n", stderr)

// Output Swift file
print("""
//
//  GlyphMappings.generated.swift
//  SwiftShortcuts
//
//  Auto-generated glyph ID → SF Symbol mappings.
//  Generated: \(ISO8601DateFormatter().string(from: Date()))
//
//  To regenerate: swift Scripts/DumpGlyphMappings.swift > Sources/SwiftShortcuts/Internal/GlyphMappings.generated.swift
//

// swiftlint:disable file_length

extension GlyphMappings {
    static let mappings: [UInt16: String] = [
""")

for (glyphID, symbolName) in mappings {
    print("        \(glyphID): \"\(symbolName)\",")
}

print("""
    ]
}

// swiftlint:enable file_length
""")
