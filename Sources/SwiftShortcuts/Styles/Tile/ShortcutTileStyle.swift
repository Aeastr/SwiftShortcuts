//
//  ShortcutTileStyle.swift
//  SwiftShortcuts
//

import SwiftUI

// MARK: - Style Protocol

/// Protocol for defining the visual style of a shortcut tile
public protocol ShortcutTileStyle: Sendable {
    associatedtype Body: View

    /// Creates the view for the tile with the given configuration
    @MainActor @ViewBuilder
    func makeBody(configuration: ShortcutTileStyleConfiguration) -> Body
}

// MARK: - Configuration

/// Configuration passed to tile styles
public struct ShortcutTileStyleConfiguration: Sendable {
    /// The shortcut's display name
    public let name: String

    /// The shortcut's icon image
    public let icon: Image?

    /// The SF Symbol name for the shortcut's glyph icon
    public let glyphSymbol: String?

    /// The shortcut's background gradient (nil = use `.foregroundStyle()` from environment)
    public let gradient: LinearGradient?

    /// Whether the tile is currently loading
    public let isLoading: Bool

    /// The iCloud URL for the shortcut
    public let url: String

    /// Whether the tile is currently being pressed
    public let isPressed: Bool

    public init(
        name: String,
        icon: Image?,
        glyphSymbol: String?,
        gradient: LinearGradient?,
        isLoading: Bool,
        url: String,
        isPressed: Bool = false
    ) {
        self.name = name
        self.icon = icon
        self.glyphSymbol = glyphSymbol
        self.gradient = gradient
        self.isLoading = isLoading
        self.url = url
        self.isPressed = isPressed
    }
}

// MARK: - Environment Key

private struct ShortcutTileStyleKey: EnvironmentKey {
    static let defaultValue: any ShortcutTileStyle = DefaultShortcutTileStyle()
}

extension EnvironmentValues {
    var shortcutTileStyle: any ShortcutTileStyle {
        get { self[ShortcutTileStyleKey.self] }
        set { self[ShortcutTileStyleKey.self] = newValue }
    }
}

// MARK: - Internal Button Style

/// Internal button style that captures press state and delegates to the tile style
struct TileButtonStyle: ButtonStyle {
    let baseConfiguration: ShortcutTileStyleConfiguration
    let style: any ShortcutTileStyle

    func makeBody(configuration: Configuration) -> some View {
        // Create configuration with current press state
        let tileConfig = ShortcutTileStyleConfiguration(
            name: baseConfiguration.name,
            icon: baseConfiguration.icon,
            glyphSymbol: baseConfiguration.glyphSymbol,
            gradient: baseConfiguration.gradient,
            isLoading: baseConfiguration.isLoading,
            url: baseConfiguration.url,
            isPressed: configuration.isPressed
        )

        AnyView(style.makeBody(configuration: tileConfig))
    }
}

// MARK: - View Modifier

extension View {
    /// Applies a custom style to shortcut tiles within this view hierarchy.
    ///
    /// - Parameter style: The style to apply
    /// - Returns: A view with the style applied
    public func shortcutTileStyle(_ style: some ShortcutTileStyle) -> some View {
        environment(\.shortcutTileStyle, style)
    }
}
