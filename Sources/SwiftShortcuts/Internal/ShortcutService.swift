//
//  ShortcutService.swift
//  SwiftShortcuts
//

import SwiftUI
import Foundation

// MARK: - API Response Structures

struct CloudKitResponse: Codable {
    let recordName: String
    let fields: Fields

    struct Fields: Codable {
        let name: ValueWrapper<String>
        let icon_color: ValueWrapper<Int64>
        let icon_glyph: ValueWrapper<Int64>
        let icon: AssetField?
        let shortcut: AssetField?

        struct ValueWrapper<T: Codable>: Codable {
            let value: T
        }

        struct AssetField: Codable {
            let value: AssetValue

            struct AssetValue: Codable {
                let downloadURL: String
            }
        }
    }
}

// MARK: - Fetched Shortcut Data

struct ShortcutData: Sendable {
    let id: String
    let name: String
    let iconColor: Int64
    let iconGlyph: Int64
    let iconURL: String?
    let shortcutURL: String?
    let iCloudLink: String

    var gradient: LinearGradient {
        ShortcutColors.gradient(for: iconColor)
    }

    /// The glyph as a Unicode character (Private Use Area)
    var glyphCharacter: Character? {
        guard let scalar = Unicode.Scalar(UInt32(iconGlyph)) else { return nil }
        return Character(scalar)
    }
}

// MARK: - Service

struct ShortcutService: Sendable {
    static let shared = ShortcutService()

    func fetchMetadata(from iCloudLink: String) async throws -> ShortcutData {
        guard let shortcutID = extractShortcutID(from: iCloudLink) else {
            throw URLError(.badURL)
        }

        let apiURL = "https://www.icloud.com/shortcuts/api/records/\(shortcutID)"

        guard let url = URL(string: apiURL) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let cloudKitResponse = try JSONDecoder().decode(CloudKitResponse.self, from: data)

        return ShortcutData(
            id: cloudKitResponse.recordName,
            name: cloudKitResponse.fields.name.value,
            iconColor: cloudKitResponse.fields.icon_color.value,
            iconGlyph: cloudKitResponse.fields.icon_glyph.value,
            iconURL: cloudKitResponse.fields.icon?.value.downloadURL,
            shortcutURL: constructAssetURL(cloudKitResponse.fields.shortcut?.value.downloadURL),
            iCloudLink: normalizeShortcutURL(iCloudLink)
        )
    }

    func fetchIcon(from urlString: String) async -> Image? {
        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
#if canImport(UIKit)
            if let uiImage = UIImage(data: data) {
                return Image(uiImage: uiImage)
            }
#else
            if let nsImage = NSImage(data: data) {
                return Image(nsImage: nsImage)
            }
#endif
        } catch {
            print("Failed to load shortcut icon: \(error)")
        }
        return nil
    }

    func fetchWorkflowActions(from urlString: String) async throws -> [WorkflowAction] {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        guard let plist = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        ) as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }

        guard let actions = plist["WFWorkflowActions"] as? [[String: Any]] else {
            return []
        }

        return actions.compactMap { dict -> WorkflowAction? in
            guard let identifier = dict["WFWorkflowActionIdentifier"] as? String else {
                return nil
            }

            let params = dict["WFWorkflowActionParameters"] as? [String: Any]

            // DEBUG: print all actions with their params
            let isMapped = actionMappings[identifier] != nil
            print("\(isMapped ? "✓" : "📍") \(identifier)")
            if let params {
                print("   Keys: \(params.keys.sorted())")
                for (key, value) in params.sorted(by: { $0.key < $1.key }) {
                    print("   \(key): \(value)")
                }
            }
            print("")

            // Extract control flow mode if present
            var controlFlowMode: WorkflowAction.ControlFlowMode?
            if let modeValue = params?["WFControlFlowMode"] as? Int {
                controlFlowMode = WorkflowAction.ControlFlowMode(rawValue: modeValue)
            }

            // Extract subtitle/context based on action type
            let subtitle = Self.extractSubtitle(identifier: identifier, params: params, controlFlowMode: controlFlowMode)

            return WorkflowAction(identifier: identifier, controlFlowMode: controlFlowMode, subtitle: subtitle)
        }
    }

    private func extractShortcutID(from link: String) -> String? {
        guard let url = URL(string: link) else { return nil }
        let path = url.path

        if path.contains("/api/records/") {
            return path.components(separatedBy: "/api/records/").last
        }

        return url.lastPathComponent
    }

    private func normalizeShortcutURL(_ link: String) -> String {
        if link.contains("/api/records/") {
            if let shortcutID = extractShortcutID(from: link) {
                return "https://www.icloud.com/shortcuts/\(shortcutID)"
            }
        }
        return link
    }

    /// Constructs a usable asset URL by replacing the ${f} placeholder.
    private func constructAssetURL(_ templateURL: String?) -> String? {
        guard let templateURL else { return nil }
        return templateURL.replacingOccurrences(of: "${f}", with: "shortcut.plist")
    }

    // MARK: - Subtitle Extraction

    private static func extractSubtitle(
        identifier: String,
        params: [String: Any]?,
        controlFlowMode: WorkflowAction.ControlFlowMode?
    ) -> String? {
        guard let params else { return nil }

        // Don't show subtitles for end markers
        if controlFlowMode == .end { return nil }

        // Menu items show their title
        if controlFlowMode == .middle,
           identifier == "is.workflow.actions.choosefrommenu",
           let title = params["WFMenuItemTitle"] as? String {
            return title
        }

        // Conditionals use the condition mappings
        if identifier == "is.workflow.actions.conditional", controlFlowMode == .start {
            let condition: Int
            if let c = params["WFCondition"] as? Int {
                condition = c
            } else if let c = params["WFCondition"] as? Int64 {
                condition = Int(c)
            } else {
                condition = 100 // default: has any value
            }

            // Extract input name (e.g., "Notes", "Upcoming Events")
            var inputName: String?
            if let input = params["WFInput"] as? [String: Any],
               let variable = input["Variable"] as? [String: Any],
               let value = variable["Value"] as? [String: Any],
               let name = value["OutputName"] as? String {
                inputName = name
            }

            if let format = conditionMappings[condition] {
                var result = format
                if format.contains("%@") {
                    let value = extractValue(from: params, keys: ["WFConditionalActionString", "WFNumberValue"])
                    result = format.replacingOccurrences(of: "%@", with: value ?? "?")
                }
                // Prepend input name if available
                if let name = inputName {
                    return "\(name) \(result)"
                }
                return result
            }
            return "condition #\(condition)"
        }

        // Use subtitleKeys from mappings if available (join multiple values)
        if let info = actionMappings[identifier], !info.subtitleKeys.isEmpty {
            let values = info.subtitleKeys.compactMap { extractValue(from: params, keys: [$0]) }
            if !values.isEmpty {
                return values.joined(separator: " · ")
            }
        }

        // Fallback: try ANY key that has a useful value
        // Skip technical/internal keys
        let skipKeys: Set<String> = [
            "UUID", "GroupingIdentifier", "WFControlFlowMode",
            "WFSerializationType", "FollowUp"
        ]

        let keys = params.keys.filter { !skipKeys.contains($0) }.sorted()

        // First pass: prefer direct strings (most readable)
        for key in keys {
            if let str = params[key] as? String, !str.isEmpty {
                return formatSubtitle(str)
            }
        }

        // Second pass: try nested structures
        for key in keys {
            if let value = extractValue(from: params, keys: [key]) {
                return value
            }
        }

        return nil
    }

    /// Extracts a displayable value from params, trying multiple keys.
    private static func extractValue(from params: [String: Any], keys: [String]) -> String? {
        for key in keys {
            // Direct string
            if let str = params[key] as? String, !str.isEmpty {
                return formatSubtitle(str)
            }
            // Number (skip 0/1 as they're usually boolean flags)
            if let num = params[key] as? NSNumber {
                let intValue = num.intValue
                if intValue != 0 && intValue != 1 {
                    return "\(num)"
                }
            }
            // Serialized token (WFTextTokenString)
            if let dict = params[key] as? [String: Any],
               let text = dict["Value"] as? [String: Any],
               let string = text["string"] as? String,
               !string.isEmpty {
                return formatSubtitle(string)
            }
        }
        return nil
    }

    /// Formats a subtitle string, filtering out placeholder-only values.
    private static func formatSubtitle(_ string: String) -> String? {
        // Filter out strings that are only placeholder characters (U+FFFC)
        let cleaned = string.replacingOccurrences(of: "\u{FFFC}", with: "").trimmingCharacters(in: .whitespaces)
        if cleaned.isEmpty { return nil }

        // Truncate long strings
        return cleaned.count > 40 ? String(cleaned.prefix(40)) + "..." : cleaned
    }
}
