#!/usr/bin/env swift
//
//  InspectGlyph.swift
//  SwiftShortcuts
//
//  Inspect what a glyph ID actually maps to internally.
//  Run with: swift Scripts/InspectGlyph.swift [glyph_id]
//

import Foundation
import AppKit
import ObjectiveC

// Load frameworks
Bundle(path: "/System/Library/PrivateFrameworks/WorkflowKit.framework")?.load()
Bundle(path: "/System/Library/PrivateFrameworks/WorkflowUIServices.framework")?.load()

let glyphID: UInt16 = CommandLine.arguments.count > 1 ? UInt16(CommandLine.arguments[1]) ?? 59446 : 59446

print("=== Inspecting Glyph \(glyphID) ===\n")

// Get WFWorkflowIcon class
guard let workflowIconClass: AnyClass = NSClassFromString("WFWorkflowIcon") else {
    print("Failed to get WFWorkflowIcon class")
    exit(1)
}

// Create icon
typealias InitMethodType = @convention(c) (AnyObject, Selector, UInt64, UInt16, NSData?) -> AnyObject?

let allocSel = NSSelectorFromString("alloc")
let initSel = NSSelectorFromString("initWithBackgroundColorValue:glyphCharacter:customImageData:")

guard let allocated = (workflowIconClass as AnyObject).perform(allocSel)?.takeUnretainedValue(),
      let initMethod = class_getInstanceMethod(workflowIconClass, initSel) else {
    print("Failed to allocate")
    exit(1)
}

let initFunc = unsafeBitCast(method_getImplementation(initMethod), to: InitMethodType.self)
guard let workflowIcon = initFunc(allocated, initSel, 0x4A90E2FF, glyphID, nil) as? NSObject else {
    print("Failed to init")
    exit(1)
}

// Get the WFIcon
let iconSel = NSSelectorFromString("icon")
guard let wfIcon = workflowIcon.perform(iconSel)?.takeUnretainedValue() as? NSObject else {
    print("Failed to get icon")
    exit(1)
}

print("WFIcon type: \(type(of: wfIcon))")
print("WFIcon class: \(NSStringFromClass(type(of: wfIcon)))")

// Inspect WFSymbolIcon properties
var propCount: UInt32 = 0
if let properties = class_copyPropertyList(type(of: wfIcon), &propCount) {
    print("\nProperties:")
    for i in 0..<Int(propCount) {
        let name = String(cString: property_getName(properties[i]))
        print("  - \(name)")

        // Try to get the value
        let getter = NSSelectorFromString(name)
        if wfIcon.responds(to: getter) {
            if let value = wfIcon.perform(getter)?.takeUnretainedValue() {
                print("    = \(value)")
            }
        }
    }
    free(properties)
}

// Check specific properties we expect
print("\n=== Checking expected properties ===")

let propsToCheck = ["symbolName", "symbolColor", "background", "renderingMode", "symbolColors"]
for prop in propsToCheck {
    let sel = NSSelectorFromString(prop)
    if wfIcon.responds(to: sel) {
        if let value = wfIcon.perform(sel)?.takeUnretainedValue() {
            print("\(prop) = \(value)")
        } else {
            print("\(prop) = (nil or non-object)")
        }
    } else {
        print("\(prop) - not found")
    }
}

// Try to render just the symbol without background
print("\n=== Trying to render without background ===")

// Try creating WFSymbolIcon directly
if let symbolIconClass: AnyClass = NSClassFromString("WFSymbolIcon") {
    print("Found WFSymbolIcon class")

    // Get the symbolName from our existing icon
    let symbolNameSel = NSSelectorFromString("symbolName")
    if wfIcon.responds(to: symbolNameSel),
       let symbolName = wfIcon.perform(symbolNameSel)?.takeUnretainedValue() as? String {
        print("Symbol name: \(symbolName)")

        // Try creating a new WFSymbolIcon with just the symbol name
        let allocSel = NSSelectorFromString("alloc")
        let initSymbolSel = NSSelectorFromString("initWithSymbolName:")

        if let allocated = (symbolIconClass as AnyObject).perform(allocSel)?.takeUnretainedValue() as? NSObject,
           allocated.responds(to: initSymbolSel) {
            if let bareIcon = allocated.perform(initSymbolSel, with: symbolName)?.takeUnretainedValue() {
                print("Created bare WFSymbolIcon: \(bareIcon)")

                // Try to render it
                if let genClass: AnyClass = NSClassFromString("WFIconViewImageGenerator") {
                    typealias LoadMethodType = @convention(c) (AnyClass, Selector, AnyObject, CGSize, Int) -> NSImage?

                    let loadSel = NSSelectorFromString("loadIcon:size:style:")
                    if let loadMethod = class_getClassMethod(genClass, loadSel) {
                        let loadFunc = unsafeBitCast(method_getImplementation(loadMethod), to: LoadMethodType.self)

                        // Try different style values
                        for style in 0...3 {
                            if let image = loadFunc(genClass, loadSel, bareIcon, CGSize(width: 128, height: 128), style) {
                                print("Style \(style): \(image.size)")

                                // Save
                                if let tiffData = image.tiffRepresentation,
                                   let bitmap = NSBitmapImageRep(data: tiffData),
                                   let pngData = bitmap.representation(using: .png, properties: [:]) {
                                    let path = "/tmp/glyph-\(glyphID)-style\(style).png"
                                    try? pngData.write(to: URL(fileURLWithPath: path))
                                    print("  Saved: \(path)")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
