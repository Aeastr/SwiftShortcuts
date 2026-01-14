#!/usr/bin/env swift
//
//  FindIconSubclasses.swift
//  SwiftShortcuts
//
//  Research script for finding WFIcon subclasses and icon-related classes.
//  Run with: swift Scripts/FindIconSubclasses.swift
//

import Foundation
import AppKit

// Load frameworks
Bundle(path: "/System/Library/PrivateFrameworks/WorkflowKit.framework")?.load()
Bundle(path: "/System/Library/PrivateFrameworks/WorkflowUIServices.framework")?.load()

print("=== Testing WFIcon creation ===\n")

// Try to find common WFIcon subclass names
let classNames = [
    "WFIcon",
    "WFGlyphIcon",
    "WFWorkflowIcon",
    "WFCustomIcon",
    "WFImageIcon",
    "WFAppIcon",
    "WFSymbolIcon",
    "WFSFSymbolIcon",
    "WFShortcutIcon",
    "WFDefaultIcon",
    "WFStandardIcon",
    "WFBuiltInIcon",
]

for name in classNames {
    if let cls = NSClassFromString(name) {
        print("Found: \(name)")

        // List initializers
        var methodCount: UInt32 = 0
        if let methods = class_copyMethodList(cls, &methodCount) {
            let inits = (0..<Int(methodCount)).compactMap { i -> String? in
                let sel = NSStringFromSelector(method_getName(methods[i]))
                if sel.hasPrefix("init") {
                    return sel
                }
                return nil
            }
            if !inits.isEmpty {
                print("  Initializers: \(inits.joined(separator: ", "))")
            }
            free(methods)
        }

        // Check class methods too
        if let metaClass = object_getClass(cls) {
            var classMethodCount: UInt32 = 0
            if let classMethods = class_copyMethodList(metaClass, &classMethodCount) {
                let factories = (0..<Int(classMethodCount)).compactMap { i -> String? in
                    let sel = NSStringFromSelector(method_getName(classMethods[i]))
                    if sel.contains("icon") || sel.contains("glyph") || sel.contains("With") {
                        return sel
                    }
                    return nil
                }
                if !factories.isEmpty {
                    print("  Factory methods: \(factories.joined(separator: ", "))")
                }
                free(classMethods)
            }
        }
    }
}

// Also search for classes with "Icon" in the name
print("\n=== Searching for Icon-related classes ===")

let moreNames = [
    "WFCoreDataWorkflowIcon",
    "WFHomeScreenIcon",
    "WFIconHostingView",
    "WFIconViewImageGenerator",
]

for name in moreNames {
    if let cls = NSClassFromString(name) {
        print("\nFound: \(name)")

        var methodCount: UInt32 = 0
        if let methods = class_copyMethodList(cls, &methodCount) {
            print("  Instance methods:")
            for i in 0..<Int(methodCount) {
                let sel = NSStringFromSelector(method_getName(methods[i]))
                print("    - \(sel)")
            }
            free(methods)
        }

        if let metaClass = object_getClass(cls) {
            var classMethodCount: UInt32 = 0
            if let classMethods = class_copyMethodList(metaClass, &classMethodCount) {
                print("  Class methods:")
                for i in 0..<Int(classMethodCount) {
                    let sel = NSStringFromSelector(method_getName(classMethods[i]))
                    print("    - \(sel)")
                }
                free(classMethods)
            }
        }
    }
}
