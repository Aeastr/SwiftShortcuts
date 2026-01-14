#!/usr/bin/env swift
//
//  RenderGlyph.swift
//  SwiftShortcuts
//
//  Research script for rendering shortcut icon glyphs using private APIs.
//  Run with: swift Scripts/RenderGlyph.swift [glyph_id]
//
//  Example: swift Scripts/RenderGlyph.swift 59446
//

import Foundation
import AppKit
import ObjectiveC

// Load frameworks
Bundle(path: "/System/Library/PrivateFrameworks/WorkflowKit.framework")?.load()
Bundle(path: "/System/Library/PrivateFrameworks/WorkflowUIServices.framework")?.load()

// Parse glyph ID from arguments
let glyphID: UInt16
if CommandLine.arguments.count > 1, let id = UInt16(CommandLine.arguments[1]) {
    glyphID = id
} else {
    glyphID = 59446  // Default: document icon
}

let backgroundColor: UInt64 = 0xFF5733FF  // Orange-red color

print("=== Rendering Glyph \(glyphID) ===")
print("Background color: 0x\(String(backgroundColor, radix: 16, uppercase: true))\n")

// Get classes
guard let workflowIconClass: AnyClass = NSClassFromString("WFWorkflowIcon") else {
    print("Failed to get WFWorkflowIcon class")
    exit(1)
}

guard let imageGeneratorClass: AnyClass = NSClassFromString("WFIconViewImageGenerator") else {
    print("Failed to get WFIconViewImageGenerator class")
    exit(1)
}

// Create WFWorkflowIcon using alloc/init pattern
// The signature is: initWithBackgroundColorValue:(uint64)glyphCharacter:(WFGlyphCharacter)customImageData:(NSData*)

// We need to use NSInvocation or similar to call this
// Since WFGlyphCharacter is just a UInt16 struct, we can try calling directly

typealias InitMethodType = @convention(c) (AnyObject, Selector, UInt64, UInt16, NSData?) -> AnyObject?

let allocSel = NSSelectorFromString("alloc")
let initSel = NSSelectorFromString("initWithBackgroundColorValue:glyphCharacter:customImageData:")

// Allocate
guard let allocated = (workflowIconClass as AnyObject).perform(allocSel)?.takeUnretainedValue() else {
    print("Failed to allocate WFWorkflowIcon")
    exit(1)
}

print("Allocated WFWorkflowIcon instance")

// Get the init method
guard let initMethod = class_getInstanceMethod(workflowIconClass, initSel) else {
    print("Failed to get init method")
    exit(1)
}

let initImpl = method_getImplementation(initMethod)
let initFunc = unsafeBitCast(initImpl, to: InitMethodType.self)

// Call init
guard let icon = initFunc(allocated, initSel, backgroundColor, glyphID, nil) else {
    print("Failed to init WFWorkflowIcon")
    exit(1)
}

print("Created WFWorkflowIcon with glyph \(glyphID)")

// Get the WFIcon from the WFWorkflowIcon (it has an 'icon' property)
let iconSel = NSSelectorFromString("icon")
guard let workflowIcon = icon as? NSObject,
      workflowIcon.responds(to: iconSel),
      let wfIcon = workflowIcon.perform(iconSel)?.takeUnretainedValue() else {
    print("Failed to get WFIcon from WFWorkflowIcon")
    exit(1)
}

print("Got WFIcon: \(wfIcon)")

// Now try to render using WFIconViewImageGenerator
print("\n=== Attempting to render ===")

// loadIcon:size:style: class method
// Need to figure out what "style" is - likely an enum or struct

// First, let's see what types the method expects
let loadSel = NSSelectorFromString("loadIcon:size:style:")
guard let loadMethod = class_getClassMethod(imageGeneratorClass, loadSel) else {
    print("Failed to get loadIcon:size:style: method")
    exit(1)
}

// Get method type encoding
let typeEncoding = method_getTypeEncoding(loadMethod)
if let encoding = typeEncoding {
    print("Method type encoding: \(String(cString: encoding))")
}

// The encoding should tell us what "style" is
// Let's try calling with 0 for style (assuming it's an int/enum)

typealias LoadMethodType = @convention(c) (AnyClass, Selector, AnyObject, CGSize, Int) -> NSImage?

let loadImpl = method_getImplementation(loadMethod)
let loadFunc = unsafeBitCast(loadImpl, to: LoadMethodType.self)

let size = CGSize(width: 128, height: 128)

if let image = loadFunc(imageGeneratorClass, loadSel, wfIcon, size, 0) {
    print("Successfully generated image: \(image.size)")

    // Save to file
    let outputPath = "/tmp/glyph-\(glyphID).png"

    if let tiffData = image.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiffData),
       let pngData = bitmap.representation(using: .png, properties: [:]) {
        do {
            try pngData.write(to: URL(fileURLWithPath: outputPath))
            print("Saved to: \(outputPath)")
        } catch {
            print("Failed to save: \(error)")
        }
    }
} else {
    print("Failed to generate image")

    // Try with different style values
    print("\nTrying different style values...")
    for style in 1...5 {
        if let image = loadFunc(imageGeneratorClass, loadSel, wfIcon, size, style) {
            print("Style \(style) worked: \(image.size)")
            break
        }
    }
}
