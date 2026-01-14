//
//  FetchShortcut.swift
//  SwiftShortcuts
//
//  Fetches shortcut metadata from iCloud and outputs it as JSON.
//
//  Usage:
//    swift run sstools fetch https://www.icloud.com/shortcuts/abc123
//    swift run sstools fetch abc123
//

import ArgumentParser
import Foundation

struct FetchShortcut: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "fetch",
        abstract: "Fetch shortcut data from iCloud and output as JSON"
    )

    @Argument(help: "Shortcut URL or ID (e.g., https://www.icloud.com/shortcuts/abc123 or just abc123)")
    var shortcut: String

    @Flag(name: .shortAndLong, help: "Pretty print the JSON output")
    var pretty: Bool = false

    @Flag(name: .shortAndLong, help: "Include workflow actions in output")
    var actions: Bool = false

    func run() async throws {
        let shortcutID = extractShortcutID(from: shortcut)
        let apiURL = "https://www.icloud.com/shortcuts/api/records/\(shortcutID)"

        guard let url = URL(string: apiURL) else {
            throw ValidationError("Invalid shortcut URL or ID")
        }

        fputs("Fetching shortcut \(shortcutID)...\n", stderr)

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ValidationError("Invalid response from server")
        }

        guard httpResponse.statusCode == 200 else {
            throw ValidationError("Server returned status \(httpResponse.statusCode). Shortcut may not exist or is private.")
        }

        let cloudKitResponse = try JSONDecoder().decode(CloudKitResponse.self, from: data)

        var output = ShortcutOutput(
            id: cloudKitResponse.recordName,
            name: cloudKitResponse.fields.name.value,
            iconColor: cloudKitResponse.fields.icon_color.value,
            iconGlyph: cloudKitResponse.fields.icon_glyph.value,
            iconURL: cloudKitResponse.fields.icon?.value.downloadURL,
            shortcutURL: constructAssetURL(cloudKitResponse.fields.shortcut?.value.downloadURL),
            iCloudLink: "https://www.icloud.com/shortcuts/\(shortcutID)"
        )

        if actions, let shortcutURL = output.shortcutURL {
            fputs("Fetching workflow actions...\n", stderr)
            output.actions = try await fetchWorkflowActions(from: shortcutURL)
        }

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if pretty {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }

        let jsonData = try encoder.encode(output)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        }

        fputs("Done.\n", stderr)
    }

    // MARK: - Helpers

    private func extractShortcutID(from input: String) -> String {
        // If it looks like a URL, extract the ID
        if input.contains("icloud.com") || input.contains("/") {
            guard let url = URL(string: input) else { return input }
            let path = url.path

            if path.contains("/api/records/") {
                return path.components(separatedBy: "/api/records/").last ?? input
            }

            return url.lastPathComponent
        }

        // Otherwise, assume it's already an ID
        return input
    }

    private func constructAssetURL(_ templateURL: String?) -> String? {
        guard let templateURL else { return nil }
        return templateURL.replacingOccurrences(of: "${f}", with: "shortcut.plist")
    }

    private func fetchWorkflowActions(from urlString: String) async throws -> [ActionOutput] {
        guard let url = URL(string: urlString) else {
            throw ValidationError("Invalid shortcut URL")
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        guard let plist = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        ) as? [String: Any] else {
            throw ValidationError("Could not parse shortcut plist")
        }

        guard let actions = plist["WFWorkflowActions"] as? [[String: Any]] else {
            return []
        }

        return actions.compactMap { dict -> ActionOutput? in
            guard let identifier = dict["WFWorkflowActionIdentifier"] as? String else {
                return nil
            }

            let params = dict["WFWorkflowActionParameters"] as? [String: Any]
            var controlFlowMode: Int?
            if let mode = params?["WFControlFlowMode"] as? Int {
                controlFlowMode = mode
            }

            return ActionOutput(
                identifier: identifier,
                controlFlowMode: controlFlowMode
            )
        }
    }
}

// MARK: - CloudKit Response (mirrors ShortcutService)

private struct CloudKitResponse: Codable {
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

// MARK: - Output Structures

private struct ShortcutOutput: Codable {
    let id: String
    let name: String
    let iconColor: Int64
    let iconGlyph: Int64
    let iconURL: String?
    let shortcutURL: String?
    let iCloudLink: String
    var actions: [ActionOutput]?
}

private struct ActionOutput: Codable {
    let identifier: String
    let controlFlowMode: Int?
}
