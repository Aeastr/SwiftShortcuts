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

        // Fallback: split last component using common words
        let parts = identifier.split(separator: ".")
        if let last = parts.last {
            return splitIdentifier(String(last))
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
        if identifier.contains("llm") || identifier.contains("intelligence") { return "sparkles" }
        if identifier.contains("delete") { return "trash" }
        if identifier.contains("transcribe") { return "waveform" }
        if identifier.contains("record") { return "mic" }
        if identifier.contains("audio") { return "waveform" }
        if identifier.contains("video") { return "video" }
        if identifier.contains("camera") { return "camera" }
        if identifier.contains("photo") { return "photo" }
        if identifier.contains("image") { return "photo" }
        if identifier.contains("calendar") { return "calendar" }
        if identifier.contains("reminder") { return "checklist" }
        if identifier.contains("note") { return "note.text" }
        if identifier.contains("alert") { return "exclamationmark.bubble" }
        if identifier.contains("notification") { return "bell" }
        if identifier.contains("conditional") { return "arrow.triangle.branch" }
        if identifier.contains("repeat") { return "repeat" }
        if identifier.contains("text") { return "text.alignleft" }
        if identifier.contains("app") { return "app" }
        if identifier.contains("mail") { return "envelope" }
        if identifier.contains("message") { return "message" }
        if identifier.contains("web") || identifier.contains("url") { return "globe" }
        if identifier.contains("file") || identifier.contains("document") { return "doc" }
        if identifier.contains("folder") { return "folder" }
        if identifier.contains("clipboard") { return "clipboard" }
        if identifier.contains("share") { return "square.and.arrow.up" }
        if identifier.contains("download") { return "arrow.down.circle" }
        if identifier.contains("upload") { return "arrow.up.circle" }
        if identifier.contains("location") { return "location" }
        if identifier.contains("map") { return "map" }
        if identifier.contains("weather") { return "cloud.sun" }
        if identifier.contains("music") { return "music.note" }
        if identifier.contains("play") { return "play" }
        if identifier.contains("pause") { return "pause" }
        if identifier.contains("stop") { return "stop" }
        if identifier.contains("timer") { return "timer" }
        if identifier.contains("alarm") { return "alarm" }
        if identifier.contains("health") { return "heart" }
        if identifier.contains("workout") { return "figure.run" }
        if identifier.contains("home") { return "house" }
        if identifier.contains("device") { return "iphone" }
        if identifier.contains("bluetooth") { return "bluetooth" }
        if identifier.contains("wifi") { return "wifi" }
        if identifier.contains("brightness") { return "sun.max" }
        if identifier.contains("volume") { return "speaker.wave.2" }
        if identifier.contains("flashlight") { return "flashlight.on.fill" }
        if identifier.contains("qr") { return "qrcode" }
        if identifier.contains("scan") { return "barcode.viewfinder" }
        if identifier.contains("translate") { return "character.book.closed" }
        if identifier.contains("dictionary") { return "character.book.closed" }
        if identifier.contains("calculate") { return "function" }
        if identifier.contains("math") { return "function" }
        if identifier.contains("script") { return "terminal" }
        if identifier.contains("ssh") { return "terminal" }

        return "gearshape"
    }
}
