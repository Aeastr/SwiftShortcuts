//
//  ShortcutActionsViewStyle.swift
//  SwiftShortcuts
//

import SwiftUI

// MARK: - Style Protocol

/// Protocol for defining the visual style of the shortcut actions view.
public protocol ShortcutActionsViewStyle: Sendable {
    associatedtype Body: View

    /// Creates the view for the actions list with the given configuration.
    @MainActor @ViewBuilder
    func makeBody(configuration: ShortcutActionsViewStyleConfiguration) -> Body
}

// MARK: - Configuration

/// Configuration passed to actions view styles.
public struct ShortcutActionsViewStyleConfiguration: Sendable {
    /// The shortcut's display name.
    public let shortcutName: String

    /// The workflow actions in order.
    public let actions: [WorkflowAction]

    /// The shortcut's background gradient.
    public let gradient: LinearGradient?

    /// Whether the view is currently loading.
    public let isLoading: Bool

    public init(
        shortcutName: String,
        actions: [WorkflowAction],
        gradient: LinearGradient?,
        isLoading: Bool
    ) {
        self.shortcutName = shortcutName
        self.actions = actions
        self.gradient = gradient
        self.isLoading = isLoading
    }
}

// MARK: - Environment Key

private struct ShortcutActionsViewStyleKey: EnvironmentKey {
    static let defaultValue: any ShortcutActionsViewStyle = DefaultShortcutActionsViewStyle()
}

extension EnvironmentValues {
    var shortcutActionsViewStyle: any ShortcutActionsViewStyle {
        get { self[ShortcutActionsViewStyleKey.self] }
        set { self[ShortcutActionsViewStyleKey.self] = newValue }
    }
}

// MARK: - View Modifier

extension View {
    /// Applies a custom style to shortcut actions views within this view hierarchy.
    ///
    /// - Parameter style: The style to apply
    /// - Returns: A view with the style applied
    public func shortcutActionsViewStyle(_ style: some ShortcutActionsViewStyle) -> some View {
        environment(\.shortcutActionsViewStyle, style)
    }
}
