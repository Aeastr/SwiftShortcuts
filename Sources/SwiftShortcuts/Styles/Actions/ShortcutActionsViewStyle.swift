//
//  ShortcutActionsViewStyle.swift
//  SwiftShortcuts
//

import SwiftUI

// MARK: - Style Protocol

/// Protocol for defining the visual style of the shortcut actions view.
///
/// Only `makeBody` is required. The other methods have default implementations
/// that you can override for customization, or use as building blocks in your own `makeBody`.
public protocol ShortcutActionsViewStyle: Sendable {
    associatedtype Body: View
    associatedtype HeaderBody: View
    associatedtype NodeBody: View
    associatedtype LoadingBody: View
    associatedtype EmptyBody: View

    /// Creates the main container view. **(Required)**
    @MainActor @ViewBuilder
    func makeBody(configuration: ShortcutActionsViewStyleConfiguration) -> Body

    /// Creates the header showing shortcut name and action count. *(Has default)*
    @MainActor @ViewBuilder
    func makeHeader(configuration: ShortcutActionsViewStyleConfiguration) -> HeaderBody

    /// Creates a single action node. *(Has default)*
    @MainActor @ViewBuilder
    func makeNode(action: WorkflowAction, gradient: LinearGradient?) -> NodeBody

    /// Creates the loading state view. *(Has default)*
    @MainActor @ViewBuilder
    func makeLoadingState() -> LoadingBody

    /// Creates the empty state view. *(Has default)*
    @MainActor @ViewBuilder
    func makeEmptyState() -> EmptyBody
}

// MARK: - Default Implementations

extension ShortcutActionsViewStyle {
    @MainActor @ViewBuilder
    public func makeHeader(configuration: ShortcutActionsViewStyleConfiguration) -> some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(configuration.gradient ?? LinearGradient(colors: [.gray], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 24, height: 24)

                if let icon = configuration.icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
            }

            Text(configuration.shortcutName)
                .font(.headline)

            Spacer()

            Text("\(configuration.actions.count) actions")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    @MainActor @ViewBuilder
    public func makeNode(action: WorkflowAction, gradient: LinearGradient?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: action.systemImage)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(action.displayName)
                    .font(.subheadline)

                if let subtitle = action.subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    @MainActor @ViewBuilder
    public func makeLoadingState() -> some View {
        HStack {
            Spacer()
            ProgressView()
                .padding()
            Spacer()
        }
    }

    @MainActor @ViewBuilder
    public func makeEmptyState() -> some View {
        HStack {
            Spacer()
            Text("No actions")
                .foregroundStyle(.secondary)
                .padding()
            Spacer()
        }
    }
}

// MARK: - Configuration

/// Configuration passed to actions view styles.
public struct ShortcutActionsViewStyleConfiguration: Sendable {
    /// The shortcut's display name.
    public let shortcutName: String

    /// The shortcut's custom icon (if set).
    public let icon: Image?

    /// The workflow actions in order.
    public let actions: [WorkflowAction]

    /// The shortcut's background gradient.
    public let gradient: LinearGradient?

    /// Whether the view is currently loading.
    public let isLoading: Bool

    public init(
        shortcutName: String,
        icon: Image? = nil,
        actions: [WorkflowAction],
        gradient: LinearGradient?,
        isLoading: Bool
    ) {
        self.shortcutName = shortcutName
        self.icon = icon
        self.actions = actions
        self.gradient = gradient
        self.isLoading = isLoading
    }
}

// MARK: - Environment Key

private struct ShortcutActionsViewStyleKey: EnvironmentKey {
    static let defaultValue: any ShortcutActionsViewStyle = FlowShortcutActionsViewStyle()
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

// MARK: - Previews

#Preview("Default Components") {
    let sampleActions = [
        WorkflowAction(identifier: "is.workflow.actions.gettext", subtitle: "Hello World"),
        WorkflowAction(identifier: "is.workflow.actions.showresult"),
    ]

    let config = ShortcutActionsViewStyleConfiguration(
        shortcutName: "Sample Shortcut",
        actions: sampleActions,
        gradient: ShortcutGradient.blue,
        isLoading: false
    )

    ScrollView {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            GroupBox("makeHeader") {
                ListShortcutActionsViewStyle()
                    .makeHeader(configuration: config)
            }

            // Nodes
            GroupBox("makeNode") {
                VStack(spacing: 0) {
                    ForEach(sampleActions) { action in
                        ListShortcutActionsViewStyle()
                            .makeNode(action: action, gradient: ShortcutGradient.blue)
                        Divider()
                    }
                }
            }

            // Loading
            GroupBox("makeLoadingState") {
                ListShortcutActionsViewStyle()
                    .makeLoadingState()
            }

            // Empty
            GroupBox("makeEmptyState") {
                ListShortcutActionsViewStyle()
                    .makeEmptyState()
            }
        }
        .padding()
    }
}

#Preview("Live Fetch") {
    ScrollView {
        ShortcutActionsView(url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f")
            .padding()
    }
}
