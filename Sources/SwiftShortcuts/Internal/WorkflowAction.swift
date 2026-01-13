//
//  WorkflowAction.swift
//  SwiftShortcuts
//

import Foundation

/// Represents a single action/step in a shortcut workflow.
public struct WorkflowAction: Identifiable, Sendable {
    public let id: UUID
    public let identifier: String
    public let controlFlowMode: ControlFlowMode?
    public let subtitle: String?

    /// Control flow mode for conditional/loop actions.
    public enum ControlFlowMode: Int, Sendable {
        case start = 0      // If, Repeat, Choose from Menu
        case middle = 1     // Otherwise, Next item
        case end = 2        // End If, End Repeat, End Menu
    }

    public init(id: UUID = UUID(), identifier: String, controlFlowMode: ControlFlowMode? = nil, subtitle: String? = nil) {
        self.id = id
        self.identifier = identifier
        self.controlFlowMode = controlFlowMode
        self.subtitle = subtitle
    }

    /// Whether this is a control flow marker (Otherwise, End If, etc.)
    public var isControlFlowMarker: Bool {
        guard let mode = controlFlowMode else { return false }
        return mode == .middle || mode == .end
    }

    /// Human-readable name for the action.
    public var displayName: String {
        // Handle control flow modes specially
        if let mode = controlFlowMode {
            switch (identifier, mode) {
            case ("is.workflow.actions.conditional", .start):   return "If"
            case ("is.workflow.actions.conditional", .middle):  return "Otherwise"
            case ("is.workflow.actions.conditional", .end):     return "End If"
            case ("is.workflow.actions.choosefrommenu", .start):  return "Menu"
            case ("is.workflow.actions.choosefrommenu", .middle): return "Menu Item"
            case ("is.workflow.actions.choosefrommenu", .end):    return "End Menu"
            case ("is.workflow.actions.repeat.count", .end),
                 ("is.workflow.actions.repeat.each", .end):     return "End Repeat"
            default: break
            }
        }

        // Check mappings table
        if let info = actionMappings[identifier] {
            return info.name
        }

        // Fallback: parse last component of identifier
        let parts = identifier.split(separator: ".")
        if let last = parts.last {
            return String(last).capitalized
        }

        return identifier
    }

    /// SF Symbol name for the action.
    public var systemImage: String {
        // Check mappings table
        if let info = actionMappings[identifier] {
            return info.icon
        }

        // Fallback based on identifier patterns
        if identifier.contains("calendar") { return "calendar" }
        if identifier.contains("note") { return "note.text" }
        if identifier.contains("alert") { return "exclamationmark.bubble" }
        if identifier.contains("conditional") { return "arrow.triangle.branch" }
        if identifier.contains("text") { return "text.alignleft" }
        if identifier.contains("app") { return "app" }
        if identifier.contains("photo") { return "photo" }
        if identifier.contains("mail") { return "envelope" }
        if identifier.contains("message") { return "message" }
        if identifier.contains("web") || identifier.contains("url") { return "globe" }
        if identifier.contains("file") { return "doc" }
        if identifier.contains("clipboard") { return "clipboard" }

        return "gearshape"
    }
}
