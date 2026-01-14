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

// Load frameworks
Bundle(path: "/System/Library/PrivateFrameworks/WorkflowKit.framework")?.load()
Bundle(path: "/System/Library/PrivateFrameworks/WorkflowUIServices.framework")?.load()

// Parse glyph ID from arguments
let glyphID: Int
if CommandLine.arguments.count > 1, let id = Int(CommandLine.arguments[1]) {
    glyphID = id
} else {
    glyphID = 59446  // Default: document icon
}

print("=== Rendering Glyph \(glyphID) ===\n")

// Get classes
guard let workflowIconClass = NSClassFromString("WFWorkflowIcon") as? NSObject.Type else {
    print("Failed to get WFWorkflowIcon class")
    exit(1)
}

guard let imageGeneratorClass = NSClassFromString("WFIconViewImageGenerator") as? NSObject.Type else {
    print("Failed to get WFIconViewImageGenerator class")
    exit(1)
}

// First, let's inspect WFWorkflowIcon methods and properties to understand the API
print("=== Inspecting WFWorkflowIcon ===\n")

// Alternative approach: look at WFWorkflowIcon properties
print("\n=== Inspecting WFWorkflowIcon properties ===")

var propCount: UInt32 = 0
if let properties = class_copyPropertyList(workflowIconClass, &propCount) {
    print("Properties (\(propCount)):")
    for i in 0..<Int(propCount) {
        let name = String(cString: property_getName(properties[i]))
        if let attrs = property_getAttributes(properties[i]) {
            print("  - \(name): \(String(cString: attrs))")
        }
    }
    free(properties)
}

// Get all methods to understand how to use the class
print("\n=== WFWorkflowIcon methods ===")

var methodCount: UInt32 = 0
if let methods = class_copyMethodList(workflowIconClass, &methodCount) {
    for i in 0..<Int(methodCount) {
        let sel = NSStringFromSelector(method_getName(methods[i]))
        print("  - \(sel)")
    }
    free(methods)
}
