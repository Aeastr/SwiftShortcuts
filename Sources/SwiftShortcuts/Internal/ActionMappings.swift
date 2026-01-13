//
//  ActionMappings.swift
//  SwiftShortcuts
//
//  Reference table for Shortcuts action identifiers.
//
//  ┌────────────────────────────────────────────────────────────────────┐
//  │  CONTRIBUTIONS WELCOME!                                            │
//  │                                                                    │
//  │  This list is incomplete. Apple has hundreds of actions and we    │
//  │  can't map them all ourselves. Found an action showing the wrong  │
//  │  name or icon? Add it here and open a PR!                         │
//  │                                                                    │
//  │  Format:                                                           │
//  │  "identifier": ActionInfo("Display Name", icon: "sf.symbol")      │
//  └────────────────────────────────────────────────────────────────────┘
//

import Foundation

// MARK: - Action Info

struct ActionInfo {
    let name: String
    let icon: String
    let subtitleKey: String?  // Parameter key to use as subtitle

    init(_ name: String, icon: String, subtitle: String? = nil) {
        self.name = name
        self.icon = icon
        self.subtitleKey = subtitle
    }
}

// MARK: - Mappings Table

/// Maps action identifiers to display info.
/// Format: "identifier": ActionInfo("Display Name", icon: "sf.symbol", subtitle: "WFParamKey")
let actionMappings: [String: ActionInfo] = [

    // ┌─────────────────────────────────────────────────────────────────────────┐
    // │ CALENDAR                                                                 │
    // └─────────────────────────────────────────────────────────────────────────┘
    "is.workflow.actions.getupcomingcalendarevents": ActionInfo("Get Upcoming Events", icon: "calendar"),
    "is.workflow.actions.addcalendarevent":          ActionInfo("Add Calendar Event", icon: "calendar.badge.plus"),

    // ┌─────────────────────────────────────────────────────────────────────────┐
    // │ NOTES                                                                    │
    // └─────────────────────────────────────────────────────────────────────────┘
    "is.workflow.actions.filter.notes":   ActionInfo("Find Notes", icon: "note.text"),
    "is.workflow.actions.createnote":     ActionInfo("Create Note", icon: "square.and.pencil"),
    "is.workflow.actions.shownote":       ActionInfo("Show Note", icon: "note.text"),
    "is.workflow.actions.appendnote":     ActionInfo("Append to Note", icon: "note.text.badge.plus"),

    // ┌─────────────────────────────────────────────────────────────────────────┐
    // │ CONTROL FLOW                                                             │
    // └─────────────────────────────────────────────────────────────────────────┘
    "is.workflow.actions.conditional":     ActionInfo("If", icon: "arrow.triangle.branch"),
    "is.workflow.actions.choosefrommenu":  ActionInfo("Menu", icon: "list.bullet", subtitle: "WFMenuItemTitle"),
    "is.workflow.actions.repeat.count":    ActionInfo("Repeat", icon: "repeat", subtitle: "WFRepeatCount"),
    "is.workflow.actions.repeat.each":     ActionInfo("Repeat with Each", icon: "repeat"),

    // ┌─────────────────────────────────────────────────────────────────────────┐
    // │ ALERTS & UI                                                              │
    // └─────────────────────────────────────────────────────────────────────────┘
    "is.workflow.actions.alert":        ActionInfo("Show Alert", icon: "exclamationmark.bubble", subtitle: "WFAlertActionTitle"),
    "is.workflow.actions.ask":          ActionInfo("Ask for Input", icon: "questionmark.bubble", subtitle: "WFAskActionPrompt"),
    "is.workflow.actions.showresult":   ActionInfo("Show Result", icon: "text.bubble"),
    "is.workflow.actions.notification": ActionInfo("Show Notification", icon: "bell", subtitle: "WFNotificationTitle"),

    // ┌─────────────────────────────────────────────────────────────────────────┐
    // │ TEXT                                                                     │
    // └─────────────────────────────────────────────────────────────────────────┘
    "is.workflow.actions.gettext":       ActionInfo("Text", icon: "text.alignleft"),
    "is.workflow.actions.text.combine":  ActionInfo("Combine Text", icon: "text.append"),
    "is.workflow.actions.text.split":    ActionInfo("Split Text", icon: "text.justify"),
    "is.workflow.actions.text.replace":  ActionInfo("Replace Text", icon: "text.badge.xmark"),
    "is.workflow.actions.detect.text":   ActionInfo("Get Text from Input", icon: "text.viewfinder"),

    // ┌─────────────────────────────────────────────────────────────────────────┐
    // │ VARIABLES                                                                │
    // └─────────────────────────────────────────────────────────────────────────┘
    "is.workflow.actions.setvariable": ActionInfo("Set Variable", icon: "equal.square", subtitle: "WFVariableName"),
    "is.workflow.actions.getvariable": ActionInfo("Get Variable", icon: "equal.square", subtitle: "WFVariableName"),
    "is.workflow.actions.getvalueforkey": ActionInfo("Get Dictionary Value", icon: "key"),

    // ┌─────────────────────────────────────────────────────────────────────────┐
    // │ APPS                                                                     │
    // └─────────────────────────────────────────────────────────────────────────┘
    "is.workflow.actions.openapp": ActionInfo("Open App", icon: "app", subtitle: "WFAppName"),
    "is.workflow.actions.openurl": ActionInfo("Open URL", icon: "link"),

    // ┌─────────────────────────────────────────────────────────────────────────┐
    // │ FILES                                                                    │
    // └─────────────────────────────────────────────────────────────────────────┘
    "is.workflow.actions.documentpicker.open": ActionInfo("Select File", icon: "doc"),
    "is.workflow.actions.documentpicker.save": ActionInfo("Save File", icon: "doc.badge.arrow.up"),
    "is.workflow.actions.file.getlink":        ActionInfo("Get Link to File", icon: "link"),

    // ┌─────────────────────────────────────────────────────────────────────────┐
    // │ CLIPBOARD                                                                │
    // └─────────────────────────────────────────────────────────────────────────┘
    "is.workflow.actions.getclipboard": ActionInfo("Get Clipboard", icon: "clipboard"),
    "is.workflow.actions.setclipboard": ActionInfo("Copy to Clipboard", icon: "doc.on.clipboard"),

    // ┌─────────────────────────────────────────────────────────────────────────┐
    // │ WEB                                                                      │
    // └─────────────────────────────────────────────────────────────────────────┘
    "is.workflow.actions.getwebpagecontents": ActionInfo("Get Web Page Contents", icon: "globe"),
    "is.workflow.actions.downloadurl":        ActionInfo("Get Contents of URL", icon: "arrow.down.circle"),
    "is.workflow.actions.url":                ActionInfo("URL", icon: "link"),

    // ┌─────────────────────────────────────────────────────────────────────────┐
    // │ SCRIPTING                                                                │
    // └─────────────────────────────────────────────────────────────────────────┘
    "is.workflow.actions.runshellscript": ActionInfo("Run Shell Script", icon: "terminal"),
    "is.workflow.actions.runsshscript":   ActionInfo("Run Script over SSH", icon: "terminal"),

    // ┌─────────────────────────────────────────────────────────────────────────┐
    // │ CONTENT                                                                  │
    // └─────────────────────────────────────────────────────────────────────────┘
    "is.workflow.actions.getitemname":    ActionInfo("Get Name", icon: "textformat"),
    "is.workflow.actions.getitemtype":    ActionInfo("Get Type", icon: "info.circle"),
    "is.workflow.actions.properties":     ActionInfo("Get Details", icon: "list.bullet.rectangle"),
    "is.workflow.actions.filter.images":  ActionInfo("Find Photos", icon: "photo"),
]

// MARK: - Condition Mappings

/// Maps WFCondition values to display format.
/// The %@ placeholder is replaced with the comparison value.
///
/// Reference: Discovered by inspecting actual shortcut plist data
///
/// Conditional parameters structure:
/// ```
/// WFCondition: Int           - Condition type (see below)
/// WFControlFlowMode: Int     - 0=start, 1=otherwise, 2=end
/// GroupingIdentifier: String - Links If/Otherwise/End If together
/// WFInput: {                 - The variable being tested
///     Type: "Variable"
///     Variable: {
///         Value: {
///             OutputName: "Notes"        <- Display name we extract
///             OutputUUID: "..."
///             Type: "ActionOutput"
///         }
///         WFSerializationType: "WFTextTokenAttachment"
///     }
/// }
/// WFConditionalActionString: String  - Comparison value (for contains, equals, etc.)
/// WFNumberValue: Number              - Comparison value (for numeric conditions)
/// ```
let conditionMappings: [Int: String] = [
    // Text/String conditions (0-99)
    0:   "is %@",                   // is (equals)
    1:   "is not %@",               // is not
    2:   "contains %@",             // contains
    3:   "does not contain %@",     // does not contain
    4:   "begins with %@",          // begins with
    5:   "ends with %@",            // ends with

    // Existence conditions (100-101)
    100: "has any value",           // has any value
    101: "does not have any value", // does not have any value

    // Numeric conditions (200+?)
    200: "is greater than %@",
    201: "is greater than or equal to %@",
    202: "is less than %@",
    203: "is less than or equal to %@",
]
