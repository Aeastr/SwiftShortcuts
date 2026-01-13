//
//  ShortcutActionsView.swift
//  SwiftShortcuts
//

import SwiftUI

/// A view that displays the workflow actions/steps contained in a shortcut.
///
/// Creates a view that fetches and displays all actions from a shared shortcut:
/// ```swift
/// ShortcutActionsView(url: "https://www.icloud.com/shortcuts/abc123")
/// ```
///
/// Apply custom styles using the `.shortcutActionsViewStyle()` modifier.
public struct ShortcutActionsView: View {
    @Environment(\.shortcutActionsViewStyle) private var style

    private let url: String

    @State private var shortcutData: ShortcutData?
    @State private var actions: [WorkflowAction] = []
    @State private var isLoading = false

    /// Creates a shortcut actions view that fetches workflow steps from an iCloud share URL.
    ///
    /// - Parameter url: The iCloud share URL (e.g., "https://www.icloud.com/shortcuts/abc123")
    public init(url: String) {
        self.url = url
    }

    public var body: some View {
        let configuration = ShortcutActionsViewStyleConfiguration(
            shortcutName: shortcutData?.name ?? "",
            actions: actions,
            gradient: shortcutData?.gradient,
            isLoading: isLoading
        )

        AnyView(style.makeBody(configuration: configuration))
            .task {
                await loadActions()
            }
    }

    private func loadActions() async {
        isLoading = true
        defer { isLoading = false }

        // Small delay to stagger requests
        try? await Task.sleep(nanoseconds: UInt64.random(in: 50_000_000...150_000_000))

        do {
            // Fetch metadata first
            let data = try await ShortcutService.shared.fetchMetadata(from: url)
            shortcutData = data

            // Then fetch actions from the shortcut asset
            if let shortcutURL = data.shortcutURL {
                actions = try await ShortcutService.shared.fetchWorkflowActions(from: shortcutURL)
            }
        } catch {
            print("Failed to fetch shortcut actions: \(error)")
        }
    }
}

// MARK: - Previews

#Preview("Live Fetch") {
    ShortcutActionsView(url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f")
        .padding()
}

#Preview("Multiple") {
    ScrollView {
        VStack(spacing: 16) {
            ShortcutActionsView(url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f")
        }
        .padding()
    }
}
