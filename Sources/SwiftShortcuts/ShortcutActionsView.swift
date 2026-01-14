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
/// Or use pre-loaded data to avoid redundant fetching:
/// ```swift
/// ShortcutActionsView(data: shortcutData, actions: actions)
/// ```
///
/// Apply custom styles using the `.shortcutActionsViewStyle()` modifier.
public struct ShortcutActionsView: View {
    @Environment(\.shortcutActionsViewStyle) private var style

    // Source of data
    private enum DataSource {
        case url(String)  // Fetches everything
        case partial(data: ShortcutData)  // Has metadata (including icon), fetches only actions
        case complete(data: ShortcutData, actions: [WorkflowAction])  // All data provided
    }

    private let dataSource: DataSource

    // State only for data the view fetches itself
    @State private var fetchedData: ShortcutData?
    @State private var fetchedActions: [WorkflowAction] = []
    @State private var isLoading = false

    // Computed properties resolve the right data based on source
    private var effectiveData: ShortcutData? {
        switch dataSource {
        case .url:
            return fetchedData
        case .partial(let data), .complete(let data, _):
            return data
        }
    }

    private var effectiveActions: [WorkflowAction] {
        switch dataSource {
        case .url, .partial:
            return fetchedActions
        case .complete(_, let actions):
            return actions
        }
    }

    // MARK: - URL-based Initializer

    /// Creates a shortcut actions view that fetches workflow steps from an iCloud share URL.
    ///
    /// - Parameter url: The iCloud share URL (e.g., "https://www.icloud.com/shortcuts/abc123")
    public init(url: String) {
        self.dataSource = .url(url)
    }

    // MARK: - Pre-loaded Initializers

    /// Creates a shortcut actions view with pre-loaded metadata. Only fetches actions.
    ///
    /// Use this when you already have the shortcut metadata but still need to fetch the actions.
    /// The icon should be included in the data.
    ///
    /// - Parameter data: The pre-loaded shortcut data (including icon)
    public init(data: ShortcutData) {
        self.dataSource = .partial(data: data)
    }

    /// Creates a shortcut actions view with fully pre-loaded data. No fetching will occur.
    ///
    /// Use this when you already have all the data (e.g., from a parent view that fetched it).
    ///
    /// - Parameters:
    ///   - data: The pre-loaded shortcut data (including icon)
    ///   - actions: The pre-loaded workflow actions
    public init(data: ShortcutData, actions: [WorkflowAction]) {
        self.dataSource = .complete(data: data, actions: actions)
    }

    // MARK: - Body

    public var body: some View {
        let configuration = ShortcutActionsViewStyleConfiguration(
            shortcutName: effectiveData?.name ?? "",
            icon: effectiveData?.icon,
            image: effectiveData?.image,
            actions: effectiveActions,
            gradient: effectiveData?.gradient,
            isLoading: isLoading
        )

        AnyView(style.makeBody(configuration: configuration))
            .task {
                await loadDataIfNeeded()
            }
    }

    // MARK: - Private Methods

    private func loadDataIfNeeded() async {
        switch dataSource {
        case .url(let url):
            await loadEverything(from: url)

        case .partial(let data):
            // Only fetch actions, we already have metadata
            await loadActionsOnly(shortcutURL: data.shortcutURL)

        case .complete:
            // Everything is pre-loaded, nothing to do
            break
        }
    }

    private func loadEverything(from url: String) async {
        isLoading = true
        defer { isLoading = false }

        // Small delay to stagger requests
        try? await Task.sleep(nanoseconds: UInt64.random(in: 50_000_000...150_000_000))

        do {
            // Fetch metadata first
            var data = try await ShortcutService.shared.fetchMetadata(from: url)

            // Load custom image if available and add to data
            if let iconURL = data.iconURL {
                let image = await ShortcutService.shared.fetchImage(from: iconURL)
                data = data.with(image: image)
            }

            fetchedData = data

            // Then fetch actions from the shortcut asset
            if let shortcutURL = data.shortcutURL {
                fetchedActions = try await ShortcutService.shared.fetchWorkflowActions(from: shortcutURL)
            }
        } catch {
            print("Failed to fetch shortcut actions: \(error)")
        }
    }

    private func loadActionsOnly(shortcutURL: String?) async {
        guard let shortcutURL else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            fetchedActions = try await ShortcutService.shared.fetchWorkflowActions(from: shortcutURL)
        } catch {
            print("Failed to fetch workflow actions: \(error)")
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
