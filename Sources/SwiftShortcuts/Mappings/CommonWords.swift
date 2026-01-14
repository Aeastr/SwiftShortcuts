//
//  CommonWords.swift
//  SwiftShortcuts
//
//  Common words used to split action identifiers into readable names.
//
//  Example: "recordaudio" → "Record Audio"
//           "sendmessage" → "Send Message"
//
//  ┌────────────────────────────────────────────────────────────────────┐
//  │  CONTRIBUTIONS WELCOME!                                            │
//  │                                                                    │
//  │  See a word not splitting correctly? Add it to the list below!   │
//  │  Put longer words before shorter ones to avoid partial matches.  │
//  └────────────────────────────────────────────────────────────────────┘
//

import Foundation

/// Words to split on when parsing action identifiers.
/// Longer words should come first to avoid partial matches.
let commonWords: [String] = [
    // Longer compound words first
    "notification", "notifications",
    "assignment", "assignments",
    "clipboard",
    "calendar",
    "dictionary",
    "shortcut", "shortcuts",
    "document", "documents",
    "reminder", "reminders",
    "variable", "variables",
    "transcribe",
    "upcoming",
    "weather",
    "location",
    "workout",
    "podcast",
    "message", "messages",
    "contact", "contacts",
    "content", "contents",
    "folder", "folders",
    "extension",
    "sharing",
    "action",
    "output",
    "result",
    "script",
    "filter",
    "repeat",
    "health",
    "device",
    "toggle",
    "search",
    "update",
    "remove",
    "delete",
    "number",

    // Medium words
    "audio",
    "video",
    "photo", "photos",
    "image", "images",
    "event", "events",
    "alert",
    "input",
    "music",
    "shell",
    "match",
    "start",
    "share",
    "notes", "note",
    "files", "file",
    "items", "item",
    "home",
    "list",
    "menu",
    "wait",
    "stop",
    "edit",
    "save",
    "find",
    "send",
    "play",
    "pause",
    "record",

    // Short common words
    "get",
    "set",
    "add",
    "run",
    "open",
    "show",
    "text",
    "date",
    "time",
    "page",
    "web",
    "url",
    "app", "apps",
    "ssh",
    "if",
    "to",
    "the",
    "for",
    "and",
    "with",
    "from",
]

/// Splits an identifier component into words using commonWords.
/// Example: "recordaudio" → "Record Audio"
///          "DeleteAssignmentIntent" → "Delete Assignment"
func splitIdentifier(_ name: String) -> String {
    var result = name.lowercased()

    // Strip "intent" suffix (App Intents framework adds this to 3rd party actions)
    if result.hasSuffix("intent") {
        result = String(result.dropLast(6))
    }

    for word in commonWords {
        result = result.replacingOccurrences(
            of: word,
            with: " \(word) ",
            options: .caseInsensitive
        )
    }

    // Clean up: collapse spaces, trim, capitalize
    let words = result.split(separator: " ").map { String($0) }
    return words.map { $0.capitalized }.joined(separator: " ")
}
