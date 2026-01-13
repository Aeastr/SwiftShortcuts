//
//  WorkflowAction.swift
//  SwiftShortcuts
//

import Foundation

/// Represents a single action/step in a shortcut workflow.
public struct WorkflowAction: Identifiable, Sendable {
    public let id: UUID
    public let identifier: String

    public init(id: UUID = UUID(), identifier: String) {
        self.id = id
        self.identifier = identifier
    }

    /// Human-readable name for the action.
    public var displayName: String {
        // Check known actions first
        if let known = Self.actionNames[identifier] {
            return known
        }

        // Fallback: parse identifier
        // "is.workflow.actions.alert" → "Alert"
        // "com.apple.mobilenotes.SharingExtension" → "Notes"
        let parts = identifier.split(separator: ".")
        if let last = parts.last {
            return Self.formatActionName(String(last))
        }

        return identifier
    }

    /// SF Symbol name for the action.
    public var systemImage: String {
        if let known = Self.actionIcons[identifier] {
            return known
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

    // MARK: - Action Name Mapping

    private static let actionNames: [String: String] = [
        // Calendar
        "is.workflow.actions.getupcomingcalendarevents": "Get Upcoming Events",
        "is.workflow.actions.addcalendarevent": "Add Calendar Event",

        // Notes
        "is.workflow.actions.filter.notes": "Filter Notes",
        "is.workflow.actions.createnote": "Create Note",
        "is.workflow.actions.shownote": "Show Note",
        "is.workflow.actions.appendnote": "Append to Note",

        // Control Flow
        "is.workflow.actions.conditional": "If",
        "is.workflow.actions.choosefrommenu": "Choose from Menu",
        "is.workflow.actions.repeat.count": "Repeat",
        "is.workflow.actions.repeat.each": "Repeat with Each",

        // Alerts & UI
        "is.workflow.actions.alert": "Show Alert",
        "is.workflow.actions.ask": "Ask for Input",
        "is.workflow.actions.showresult": "Show Result",
        "is.workflow.actions.notification": "Show Notification",

        // Text
        "is.workflow.actions.gettext": "Text",
        "is.workflow.actions.text.combine": "Combine Text",
        "is.workflow.actions.text.split": "Split Text",
        "is.workflow.actions.text.replace": "Replace Text",

        // Variables
        "is.workflow.actions.setvariable": "Set Variable",
        "is.workflow.actions.getvariable": "Get Variable",

        // Apps
        "is.workflow.actions.openapp": "Open App",
        "is.workflow.actions.openurl": "Open URL",

        // Files
        "is.workflow.actions.documentpicker.open": "Select File",
        "is.workflow.actions.documentpicker.save": "Save File",

        // Clipboard
        "is.workflow.actions.getclipboard": "Get Clipboard",
        "is.workflow.actions.setclipboard": "Copy to Clipboard",

        // Web
        "is.workflow.actions.getwebpagecontents": "Get Web Page Contents",
        "is.workflow.actions.downloadurl": "Get Contents of URL",

        // Scripting
        "is.workflow.actions.runshellscript": "Run Shell Script",
        "is.workflow.actions.runsshscript": "Run Script over SSH",
    ]

    private static let actionIcons: [String: String] = [
        "is.workflow.actions.getupcomingcalendarevents": "calendar",
        "is.workflow.actions.addcalendarevent": "calendar.badge.plus",
        "is.workflow.actions.filter.notes": "note.text",
        "is.workflow.actions.createnote": "square.and.pencil",
        "is.workflow.actions.shownote": "note.text",
        "is.workflow.actions.conditional": "arrow.triangle.branch",
        "is.workflow.actions.choosefrommenu": "list.bullet",
        "is.workflow.actions.repeat.count": "repeat",
        "is.workflow.actions.repeat.each": "repeat",
        "is.workflow.actions.alert": "exclamationmark.bubble",
        "is.workflow.actions.ask": "questionmark.bubble",
        "is.workflow.actions.showresult": "text.bubble",
        "is.workflow.actions.notification": "bell",
        "is.workflow.actions.gettext": "text.alignleft",
        "is.workflow.actions.setvariable": "variable",
        "is.workflow.actions.getvariable": "variable",
        "is.workflow.actions.openapp": "app",
        "is.workflow.actions.openurl": "link",
        "is.workflow.actions.getclipboard": "clipboard",
        "is.workflow.actions.setclipboard": "clipboard",
        "is.workflow.actions.runshellscript": "terminal",
    ]

    private static func formatActionName(_ name: String) -> String {
        // Convert camelCase/lowercase to Title Case
        var result = ""
        var previousWasLower = false

        for char in name {
            if char.isUppercase && previousWasLower {
                result += " "
            }
            if result.isEmpty {
                result += char.uppercased()
            } else {
                result += String(char)
            }
            previousWasLower = char.isLowercase
        }

        return result
    }
}
