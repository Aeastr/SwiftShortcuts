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

    /// The SF Symbol name for the shortcut's icon
    public let icon: String?

    /// The shortcut's pre-rendered image (fallback when icon is nil)
    public let image: Image?

    /// The shortcut's background gradient (nil = use `.foregroundStyle()` from environment)
    public let gradient: LinearGradient?

    /// Whether the tile is currently loading
    public let isLoading: Bool

    /// The iCloud URL for the shortcut
    public let url: String

    /// Whether the tile is currently being pressed
    public let isPressed: Bool

    /// The error that occurred, if any
    public let error: ShortcutError?

    /// Whether the tile has an error
    public var hasError: Bool { error != nil }

    public init(
        name: String,
        icon: String?,
        image: Image?,
        gradient: LinearGradient?,
        isLoading: Bool,
        url: String,
        isPressed: Bool = false,
        error: ShortcutError? = nil
    ) {
        self.name = name
        self.icon = icon
        self.image = image
        self.gradient = gradient
        self.isLoading = isLoading
        self.url = url
        self.isPressed = isPressed
        self.error = error
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
            image: baseConfiguration.image,
            gradient: baseConfiguration.gradient,
            isLoading: baseConfiguration.isLoading,
            url: baseConfiguration.url,
            isPressed: configuration.isPressed,
            error: baseConfiguration.error
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
