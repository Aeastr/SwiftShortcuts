//
//  DumpGlyphs.swift
//  SwiftShortcuts
//
//  Extracts glyph ID to SF Symbol mappings from macOS Shortcuts frameworks.
//
//  Usage:
//    swift run sstools dump-glyphs > Sources/SwiftShortcuts/Internal/GlyphMappings.generated.swift
//

import ArgumentParser
import Foundation

#if canImport(AppKit)
import AppKit
#endif

struct DumpGlyphs: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "dump-glyphs",
        abstract: "Extract glyph ID to SF Symbol mappings from macOS Shortcuts frameworks"
    )

    @Option(name: [.customShort("s"), .long], help: "Start of glyph range")
    var rangeStart: UInt16 = 59392

    @Option(name: [.customShort("e"), .long], help: "End of glyph range")
    var rangeEnd: UInt16 = 62501

    func run() throws {
        #if canImport(AppKit)
        try extractGlyphs()
        #else
        throw CleanExit.message("This command requires macOS with AppKit")
        #endif
    }

    #if canImport(AppKit)
    private func extractGlyphs() throws {
        let glyphRange: ClosedRange<UInt16> = rangeStart...rangeEnd

        // Load frameworks
        guard Bundle(path: "/System/Library/PrivateFrameworks/WorkflowKit.framework")?.load() == true else {
            throw ValidationError("Failed to load WorkflowKit.framework. This tool requires macOS with Shortcuts.app installed.")
        }

        Bundle(path: "/System/Library/PrivateFrameworks/WorkflowUIServices.framework")?.load()

        // Get classes
        guard let workflowIconClass: AnyClass = NSClassFromString("WFWorkflowIcon") else {
            throw ValidationError("WFWorkflowIcon class not found")
        }

        // Setup method calls
        typealias InitMethod = @convention(c) (AnyObject, Selector, UInt64, UInt16, NSData?) -> AnyObject?

        let allocSel = NSSelectorFromString("alloc")
        let initSel = NSSelectorFromString("initWithBackgroundColorValue:glyphCharacter:customImageData:")
        let iconSel = NSSelectorFromString("icon")
        let symbolNameSel = NSSelectorFromString("symbolName")

        guard let initMethod = class_getInstanceMethod(workflowIconClass, initSel) else {
            throw ValidationError("Could not get init method")
        }

        let initFunc = unsafeBitCast(method_getImplementation(initMethod), to: InitMethod.self)

        // Extract mappings
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

        // Output
        print("""
        //
        //  GlyphMappings.generated.swift
        //  SwiftShortcuts
        //
        //  Auto-generated glyph ID → SF Symbol mappings.
        //  Generated: \(ISO8601DateFormatter().string(from: Date()))
        //
        //  Regenerate: swift run sstools dump-glyphs > Sources/SwiftShortcuts/Internal/GlyphMappings.generated.swift
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
    }
    #endif
}
