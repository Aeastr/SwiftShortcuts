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
    let created: Timestamp?
    let modified: Timestamp?

    struct Timestamp: Codable {
        let timestamp: Int64
    }

    struct Fields: Codable {
        let name: ValueWrapper<String>
        let icon_color: ValueWrapper<Int64>
        let icon_glyph: ValueWrapper<Int64>
        let icon: AssetField?
        let shortcut: AssetField?
        let signingStatus: ValueWrapper<String>?

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

/// Data fetched from the iCloud Shortcuts API or loaded from JSON.
public struct ShortcutData: Sendable, Identifiable, Codable {
    public let id: String
    public let name: String
    public let iconColor: Int64
    public let iconGlyph: Int64
    public let iconURL: String?
    public let shortcutURL: String?
    public let iCloudLink: String

    /// The loaded pre-rendered image (nil until fetched)
    public let image: Image?

    /// When the shortcut was created
    public let createdAt: Date?

    /// When the shortcut was last modified
    public let modifiedAt: Date?

    /// The signing status (e.g., "APPROVED")
    public let signingStatus: String?

    /// Number of actions in the shortcut (fetched separately)
    public let actionCount: Int?

    public var gradient: LinearGradient {
        ShortcutColors.gradient(for: iconColor)
    }

    /// The SF Symbol name for this shortcut's icon
    public var icon: String? {
        GlyphMappings.symbol(for: iconGlyph)
    }

    /// Whether the shortcut is approved/signed
    public var isApproved: Bool {
        signingStatus == "APPROVED"
    }

    public init(
        id: String,
        name: String,
        iconColor: Int64,
        iconGlyph: Int64,
        iconURL: String?,
        shortcutURL: String?,
        iCloudLink: String,
        image: Image? = nil,
        createdAt: Date? = nil,
        modifiedAt: Date? = nil,
        signingStatus: String? = nil,
        actionCount: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.iconColor = iconColor
        self.iconGlyph = iconGlyph
        self.iconURL = iconURL
        self.shortcutURL = shortcutURL
        self.iCloudLink = iCloudLink
        self.image = image
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.signingStatus = signingStatus
        self.actionCount = actionCount
    }

    /// Returns a copy of this data with the image set
    public func with(image: Image?) -> ShortcutData {
        ShortcutData(
            id: id,
            name: name,
            iconColor: iconColor,
            iconGlyph: iconGlyph,
            iconURL: iconURL,
            shortcutURL: shortcutURL,
            iCloudLink: iCloudLink,
            image: image,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            signingStatus: signingStatus,
            actionCount: actionCount
        )
    }

    /// Returns a copy of this data with the action count set
    public func with(actionCount: Int?) -> ShortcutData {
        ShortcutData(
            id: id,
            name: name,
            iconColor: iconColor,
            iconGlyph: iconGlyph,
            iconURL: iconURL,
            shortcutURL: shortcutURL,
            iCloudLink: iCloudLink,
            image: image,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            signingStatus: signingStatus,
            actionCount: actionCount
        )
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case iconColor = "icon_color"
        case iconGlyph = "icon_glyph"
        case iconURL = "icon_url"
        case shortcutURL = "shortcut_url"
        case iCloudLink = "i_cloud_link"
        case createdAt = "created_at"
        case modifiedAt = "modified_at"
        case signingStatus = "signing_status"
        case actionCount = "action_count"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        iconColor = try container.decode(Int64.self, forKey: .iconColor)
        iconGlyph = try container.decode(Int64.self, forKey: .iconGlyph)
        iconURL = try container.decodeIfPresent(String.self, forKey: .iconURL)
        shortcutURL = try container.decodeIfPresent(String.self, forKey: .shortcutURL)
        iCloudLink = try container.decode(String.self, forKey: .iCloudLink)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        modifiedAt = try container.decodeIfPresent(Date.self, forKey: .modifiedAt)
        signingStatus = try container.decodeIfPresent(String.self, forKey: .signingStatus)
        actionCount = try container.decodeIfPresent(Int.self, forKey: .actionCount)
        image = nil
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(iconColor, forKey: .iconColor)
        try container.encode(iconGlyph, forKey: .iconGlyph)
        try container.encodeIfPresent(iconURL, forKey: .iconURL)
        try container.encodeIfPresent(shortcutURL, forKey: .shortcutURL)
        try container.encode(iCloudLink, forKey: .iCloudLink)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(modifiedAt, forKey: .modifiedAt)
        try container.encodeIfPresent(signingStatus, forKey: .signingStatus)
        try container.encodeIfPresent(actionCount, forKey: .actionCount)
    }

    // MARK: - Loading from JSON

    /// Loads shortcuts from JSON data. Accepts either a single object or an array.
    public static func load(from data: Data) throws -> [ShortcutData] {
        let decoder = JSONDecoder()
        if let array = try? decoder.decode([ShortcutData].self, from: data) {
            return array
        }
        return [try decoder.decode(ShortcutData.self, from: data)]
    }

    /// Loads shortcuts from a file URL. Accepts either a single object or an array.
    public static func load(contentsOf url: URL) throws -> [ShortcutData] {
        try load(from: Data(contentsOf: url))
    }

    /// Loads shortcuts from a bundle resource. Accepts either a single object or an array.
    public static func load(resource: String, extension ext: String = "json", bundle: Bundle = .main) throws -> [ShortcutData] {
        guard let url = bundle.url(forResource: resource, withExtension: ext) else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try load(contentsOf: url)
    }
}

// MARK: - Service

struct ShortcutService: Sendable {
    static let shared = ShortcutService()

    /// Maximum length for action subtitles. Set to `nil` for no limit (default).
    nonisolated(unsafe) static var maxSubtitleLength: Int? = nil

    func fetchMetadata(from iCloudLink: String) async throws(ShortcutError) -> ShortcutData {
        guard let shortcutID = extractShortcutID(from: iCloudLink) else {
            throw .invalidURL(iCloudLink)
        }

        let apiURL = "https://www.icloud.com/shortcuts/api/records/\(shortcutID)"

        guard let url = URL(string: apiURL) else {
            throw .invalidURL(apiURL)
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw .networkError(underlying: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw .invalidResponse(statusCode: nil)
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 404 {
                throw .resourceNotFound(resource: shortcutID)
            }
            throw .invalidResponse(statusCode: httpResponse.statusCode)
        }

        let cloudKitResponse: CloudKitResponse
        do {
            cloudKitResponse = try JSONDecoder().decode(CloudKitResponse.self, from: data)
        } catch {
            throw .decodingFailed(underlying: error)
        }

        // Parse timestamps (milliseconds since 1970)
        let createdAt = cloudKitResponse.created.map { Date(timeIntervalSince1970: Double($0.timestamp) / 1000) }
        let modifiedAt = cloudKitResponse.modified.map { Date(timeIntervalSince1970: Double($0.timestamp) / 1000) }

        return ShortcutData(
            id: cloudKitResponse.recordName,
            name: cloudKitResponse.fields.name.value,
            iconColor: cloudKitResponse.fields.icon_color.value,
            iconGlyph: cloudKitResponse.fields.icon_glyph.value,
            iconURL: cloudKitResponse.fields.icon?.value.downloadURL,
            shortcutURL: constructAssetURL(cloudKitResponse.fields.shortcut?.value.downloadURL),
            iCloudLink: normalizeShortcutURL(iCloudLink),
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            signingStatus: cloudKitResponse.fields.signingStatus?.value
        )
    }

    /// Fetches metadata for multiple shortcuts in parallel.
    ///
    /// Each result is independent - failures don't affect other fetches.
    /// Results are returned in the same order as the input URLs.
    ///
    /// - Parameter urls: The iCloud share URLs to fetch
    /// - Returns: An array of results, one for each input URL
    func fetchMetadata(from urls: [String]) async -> [Result<ShortcutData, ShortcutError>] {
        await withTaskGroup(of: (Int, Result<ShortcutData, ShortcutError>).self) { group in
            for (index, url) in urls.enumerated() {
                group.addTask {
                    do {
                        let data = try await self.fetchMetadata(from: url)
                        return (index, .success(data))
                    } catch let shortcutError as ShortcutError {
                        return (index, .failure(shortcutError))
                    } catch {
                        return (index, .failure(.metadataFetchFailed(url: url, underlying: error)))
                    }
                }
            }

            var results = Array(repeating: Result<ShortcutData, ShortcutError>.failure(.invalidURL("")), count: urls.count)
            for await (index, result) in group {
                results[index] = result
            }
            return results
        }
    }

    /// Fetches shortcut metadata and its image in one call.
    ///
    /// - Parameter url: The iCloud share URL
    /// - Returns: The shortcut data with image loaded
    func fetchShortcutWithImage(from url: String) async throws(ShortcutError) -> ShortcutData {
        var data = try await fetchMetadata(from: url)

        if let iconURL = data.iconURL {
            let image = await fetchImage(from: iconURL)
            data = data.with(image: image)
        }

        return data
    }

    /// Fetches shortcut metadata, image, and workflow actions in one call.
    ///
    /// - Parameter url: The iCloud share URL
    /// - Returns: A tuple containing the shortcut data and its actions
    func fetchComplete(from url: String) async throws(ShortcutError) -> (data: ShortcutData, actions: [WorkflowAction]) {
        let data = try await fetchShortcutWithImage(from: url)

        var actions: [WorkflowAction] = []
        if let shortcutURL = data.shortcutURL {
            actions = try await fetchWorkflowActions(from: shortcutURL)
        }

        return (data, actions)
    }

    func fetchImage(from urlString: String) async -> Image? {
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
            // Image load failed - return nil to fall back to icon/gradient
        }
        return nil
    }

    func fetchWorkflowActions(from urlString: String) async throws(ShortcutError) -> [WorkflowAction] {
        guard let url = URL(string: urlString) else {
            throw .invalidURL(urlString)
        }

        let data: Data

        do {
            (data, _) = try await URLSession.shared.data(from: url)
        } catch {
            throw .networkError(underlying: error)
        }

        let plist: [String: Any]
        do {
            guard let parsed = try PropertyListSerialization.propertyList(
                from: data,
                options: [],
                format: nil
            ) as? [String: Any] else {
                throw ShortcutError.parsingFailed(reason: "Response is not a valid property list dictionary")
            }
            plist = parsed
        } catch let error as ShortcutError {
            throw error
        } catch {
            throw .parsingFailed(reason: "Failed to parse property list: \(error.localizedDescription)")
        }

        guard let actions = plist["WFWorkflowActions"] as? [[String: Any]] else {
            return []
        }

        return actions.compactMap { dict -> WorkflowAction? in
            guard let identifier = dict["WFWorkflowActionIdentifier"] as? String else {
                return nil
            }

            let params = dict["WFWorkflowActionParameters"] as? [String: Any]

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

    /// Fetches just the action count from a shortcut plist without parsing all actions.
    ///
    /// This is more lightweight than `fetchWorkflowActions` when you only need the count.
    func fetchActionCount(from urlString: String) async throws(ShortcutError) -> Int {
        guard let url = URL(string: urlString) else {
            throw .invalidURL(urlString)
        }

        let data: Data

        do {
            (data, _) = try await URLSession.shared.data(from: url)
        } catch {
            throw .networkError(underlying: error)
        }

        let plist: [String: Any]
        do {
            guard let parsed = try PropertyListSerialization.propertyList(
                from: data,
                options: [],
                format: nil
            ) as? [String: Any] else {
                throw ShortcutError.parsingFailed(reason: "Response is not a valid property list dictionary")
            }
            plist = parsed
        } catch let error as ShortcutError {
            throw error
        } catch {
            throw .parsingFailed(reason: "Failed to parse property list: \(error.localizedDescription)")
        }

        guard let actions = plist["WFWorkflowActions"] as? [[String: Any]] else {
            return 0
        }

        return actions.count
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

        // Truncate if maxSubtitleLength is set
        if let maxLength = ShortcutService.maxSubtitleLength, cleaned.count > maxLength {
            return String(cleaned.prefix(maxLength)) + "..."
        }
        return cleaned
    }
}
