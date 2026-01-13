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

            // Extract control flow mode if present
            var controlFlowMode: WorkflowAction.ControlFlowMode?
            if let params = dict["WFWorkflowActionParameters"] as? [String: Any],
               let modeValue = params["WFControlFlowMode"] as? Int {
                controlFlowMode = WorkflowAction.ControlFlowMode(rawValue: modeValue)
            }

            return WorkflowAction(identifier: identifier, controlFlowMode: controlFlowMode)
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
}
