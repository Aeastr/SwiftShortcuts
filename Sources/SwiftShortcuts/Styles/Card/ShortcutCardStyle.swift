//
//  ShortcutCardStyle.swift
//  SwiftShortcuts
//

import SwiftUI

// MARK: - Style Protocol

/// Protocol for defining the visual style of a shortcut card
public protocol ShortcutCardStyle: Sendable {
    associatedtype Body: View

    /// Creates the view for the card with the given configuration
    @MainActor @ViewBuilder
    func makeBody(configuration: ShortcutCardStyleConfiguration) -> Body
}

// MARK: - Configuration

/// Configuration passed to card styles
public struct ShortcutCardStyleConfiguration: Sendable {
    /// The shortcut's display name
    public let name: String

    /// The shortcut's icon image (if available)
    public let icon: Image?

    /// The shortcut's background gradient (nil = use `.foregroundStyle()` from environment)
    public let gradient: LinearGradient?

    /// Whether the card is currently loading
    public let isLoading: Bool

    /// The iCloud URL to open on tap
    public let url: String
}

// MARK: - Card Button Helper

struct CardButton<Content: View>: View {
    let configuration: ShortcutCardStyleConfiguration
    @ViewBuilder let content: Content
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            openShortcut()
        } label: {
            content
        }
        .buttonStyle(.plain)
    }

    private func openShortcut() {
        guard let url = URL(string: configuration.url),
              !url.lastPathComponent.isEmpty,
              let shortcutsURL = URL(string: "shortcuts://open-shortcut?id=\(url.lastPathComponent)") else {
            return
        }
        openURL(shortcutsURL)
    }
}

// MARK: - Environment Key

private struct ShortcutCardStyleKey: EnvironmentKey {
    static let defaultValue: any ShortcutCardStyle = DefaultShortcutCardStyle()
}

extension EnvironmentValues {
    var shortcutCardStyle: any ShortcutCardStyle {
        get { self[ShortcutCardStyleKey.self] }
        set { self[ShortcutCardStyleKey.self] = newValue }
    }
}
