//
//  ShortcutErrorHandler.swift
//  SwiftShortcuts
//

import SwiftUI

/// Context information about where an error occurred.
public struct ShortcutErrorContext: Sendable {
    /// The source view type that generated the error.
    public enum Source: String, Sendable {
        case tile = "ShortcutTile"
        case detail = "ShortcutDetailView"
        case actions = "ShortcutActionsView"
        case service = "ShortcutService"
    }

    /// The source view that generated the error.
    public let source: Source

    /// The URL associated with the error, if any.
    public let url: String?

    public init(source: Source, url: String? = nil) {
        self.source = source
        self.url = url
    }
}

/// A handler for shortcut-related errors.
///
/// Use this to receive error callbacks when shortcut operations fail.
/// The handler receives both the error and context about where it occurred.
public struct ShortcutErrorHandler: Sendable {
    private let handler: @Sendable (ShortcutError, ShortcutErrorContext) -> Void

    /// Creates an error handler with the given closure.
    ///
    /// - Parameter handler: A closure that receives errors and their context.
    public init(_ handler: @escaping @Sendable (ShortcutError, ShortcutErrorContext) -> Void) {
        self.handler = handler
    }

    /// Calls the error handler with the given error and context.
    public func callAsFunction(error: ShortcutError, context: ShortcutErrorContext) {
        handler(error, context)
    }
}

// MARK: - Environment Key

private struct ShortcutErrorHandlerKey: EnvironmentKey {
    static let defaultValue: ShortcutErrorHandler? = nil
}

extension EnvironmentValues {
    /// The error handler for shortcut operations.
    ///
    /// When set, shortcut views will call this handler instead of showing built-in alerts.
    public var shortcutErrorHandler: ShortcutErrorHandler? {
        get { self[ShortcutErrorHandlerKey.self] }
        set { self[ShortcutErrorHandlerKey.self] = newValue }
    }
}

// MARK: - View Modifier

extension View {
    /// Handles shortcut errors with the provided closure.
    ///
    /// When set, shortcut views will call this closure when errors occur instead of
    /// showing built-in alerts. This gives you full control over error presentation.
    ///
    /// ```swift
    /// @State private var lastError: ShortcutError?
    ///
    /// VStack {
    ///     ShortcutTile(id: "abc123")
    ///     ShortcutTile(id: "def456")
    /// }
    /// .onShortcutError { error, context in
    ///     lastError = error
    /// }
    /// .alert(item: $lastError) { error in
    ///     Alert(title: Text(error.errorDescription ?? "Error"))
    /// }
    /// ```
    ///
    /// - Parameter handler: A closure that receives errors and their context.
    /// - Returns: A view with the error handler applied.
    public func onShortcutError(
        _ handler: @escaping @Sendable (ShortcutError, ShortcutErrorContext) -> Void
    ) -> some View {
        environment(\.shortcutErrorHandler, ShortcutErrorHandler(handler))
    }
}
