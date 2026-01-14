#!/usr/bin/env swift
//
//  InspectWFIcon.swift
//  SwiftShortcuts
//
//  Research script for inspecting WFIcon class using Objective-C runtime.
//  Run with: swift Scripts/InspectWFIcon.swift
//

import Foundation
import AppKit

// Load the frameworks
let kitPath = "/System/Library/PrivateFrameworks/WorkflowKit.framework"
let uiServicesPath = "/System/Library/PrivateFrameworks/WorkflowUIServices.framework"

guard let kitBundle = Bundle(path: kitPath) else {
    print("Failed to load WorkflowKit")
    exit(1)
}

guard let uiServicesBundle = Bundle(path: uiServicesPath) else {
    print("Failed to load WorkflowUIServices")
    exit(1)
}

kitBundle.load()
uiServicesBundle.load()

print("=== Searching for WFIcon class ===\n")

// Try to get WFIcon class
if let iconClass = NSClassFromString("WFIcon") {
    print("Found WFIcon class: \(iconClass)")

    // Get instance methods
    var methodCount: UInt32 = 0
    if let methods = class_copyMethodList(iconClass, &methodCount) {
        print("\nInstance methods (\(methodCount)):")
        for i in 0..<Int(methodCount) {
            let selector = method_getName(methods[i])
            print("  - \(NSStringFromSelector(selector))")
        }
        free(methods)
    }

    // Get class methods
    if let metaClass = object_getClass(iconClass) {
        var classMethodCount: UInt32 = 0
        if let classMethods = class_copyMethodList(metaClass, &classMethodCount) {
            print("\nClass methods (\(classMethodCount)):")
            for i in 0..<Int(classMethodCount) {
                let selector = method_getName(classMethods[i])
                print("  - \(NSStringFromSelector(selector))")
            }
            free(classMethods)
        }
    }

    // Get properties
    var propCount: UInt32 = 0
    if let properties = class_copyPropertyList(iconClass, &propCount) {
        print("\nProperties (\(propCount)):")
        for i in 0..<Int(propCount) {
            let name = String(cString: property_getName(properties[i]))
            print("  - \(name)")
        }
        free(properties)
    }
} else {
    print("WFIcon class not found")
}

// Also try WFGlyphCharacter
print("\n=== Searching for WFGlyphCharacter ===\n")

if let glyphClass = NSClassFromString("WFGlyphCharacter") {
    print("Found WFGlyphCharacter: \(glyphClass)")
} else {
    print("WFGlyphCharacter not found as class (might be a struct)")
}

// Try IconViewImageGenerator
print("\n=== Searching for IconViewImageGenerator ===\n")

if let genClass = NSClassFromString("WFIconViewImageGenerator") {
    print("Found WFIconViewImageGenerator: \(genClass)")

    var methodCount: UInt32 = 0
    if let methods = class_copyMethodList(object_getClass(genClass), &methodCount) {
        print("\nClass methods (\(methodCount)):")
        for i in 0..<Int(methodCount) {
            let selector = method_getName(methods[i])
            print("  - \(NSStringFromSelector(selector))")
        }
        free(methods)
    }
} else {
    print("WFIconViewImageGenerator not found")
}
