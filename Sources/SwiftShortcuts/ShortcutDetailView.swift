//
//  ShortcutDetailView.swift
//  SwiftShortcuts
//

import SwiftUI
import Conditionals

/// A detail view for displaying shortcut information in a sheet.
///
/// Shows the shortcut's workflow actions in a flow visualization with an "Add Shortcut" button.
/// Typically presented as a sheet when tapping a `ShortcutTile` with a custom action.
///
/// ```swift
/// ShortcutTile(id: "abc123") { url in
///     showSheet = true
///     selectedURL = url
/// }
/// .sheet(isPresented: $showSheet) {
///     ShortcutDetailView(url: selectedURL)
/// }
/// ```
///
/// For pre-loaded data (avoids redundant fetching):
/// ```swift
/// ShortcutDetailView(data: shortcutData, actions: actions)
/// ```
public struct ShortcutDetailView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    // Source of data
    private enum DataSource {
        case url(String)
        case preloaded(data: ShortcutData, actions: [WorkflowAction])
    }

    private let dataSource: DataSource

    @State private var shortcutData: ShortcutData?
    @State private var actions: [WorkflowAction] = []
    @State private var isLoading = false

    // MARK: - URL-based Initializers

    /// Creates a shortcut detail view from an iCloud share URL.
    ///
    /// - Parameter url: The iCloud share URL (e.g., "https://www.icloud.com/shortcuts/abc123")
    public init(url: String) {
        self.dataSource = .url(url)
    }

    /// Creates a shortcut detail view from a shortcut ID.
    ///
    /// - Parameter id: The shortcut ID (e.g., "f00836becd2845109809720d2a70e32f")
    public init(id: String) {
        self.dataSource = .url("https://www.icloud.com/shortcuts/\(id)")
    }

    // MARK: - Pre-loaded Initializer

    /// Creates a shortcut detail view with pre-loaded data. No fetching will occur.
    ///
    /// Use this when you already have all the data to avoid redundant API calls.
    /// The icon should be included in the data.
    ///
    /// - Parameters:
    ///   - data: The pre-loaded shortcut data (including icon)
    ///   - actions: The pre-loaded workflow actions
    public init(data: ShortcutData, actions: [WorkflowAction] = []) {
        self.dataSource = .preloaded(data: data, actions: actions)
        self._shortcutData = State(initialValue: data)
        self._actions = State(initialValue: actions)
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack {
            Group {
                if let data = shortcutData {
                    ScrollView {
                        // Pass pre-loaded data to children - NO redundant fetching
                        ShortcutTile(data: data)
                            .frame(height: 110)
                            .frame(maxWidth: 180)
                            .disabled(true)

                        ShortcutActionsView(data: data, actions: actions)
                            .shortcutActionsViewStyle(.flow)
                            .padding()
                    }
                } else {
                    // Loading state
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .conditional { view in
                if #available(iOS 26, macOS 26, *) {
                    view
                        .safeAreaBar(edge: .bottom) {
                            Button {
                                addShortcut()
                            } label: {
                                Text("Add Shortcut")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.glassProminent)
                            .controlSize(.large)
                            .tint(shortcutData?.gradient ?? ShortcutGradient.blue)
                            .padding(.horizontal)
                            .padding(.top)
                        }
                } else {
                    view
                        .safeAreaInset(edge: .bottom) {
                            Button {
                                addShortcut()
                            } label: {
                                Text("Add Shortcut")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .tint(shortcutData?.gradient ?? ShortcutGradient.blue)
                            .padding(.horizontal)
                            .padding(.top)
                            .background(.bar)
                        }
                }
            }
        }
        .task {
            await loadDataIfNeeded()
        }
    }

    // MARK: - Private Methods

    private func loadDataIfNeeded() async {
        // Only load for URL-based data source
        guard case .url(let url) = dataSource else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            // Fetch metadata
            var data = try await ShortcutService.shared.fetchMetadata(from: url)

            // Fetch image and add to data
            if let iconURL = data.iconURL {
                let image = await ShortcutService.shared.fetchImage(from: iconURL)
                data = data.with(image: image)
            }

            shortcutData = data

            // Fetch actions
            if let shortcutURL = data.shortcutURL {
                actions = try await ShortcutService.shared.fetchWorkflowActions(from: shortcutURL)
            }
        } catch {
            print("Failed to fetch shortcut data: \(error)")
        }
    }

    private func addShortcut() {
        guard let data = shortcutData,
              let parsedURL = URL(string: data.iCloudLink) else {
            return
        }

        // Open the iCloud URL directly - this prompts the user to add the shortcut
        openURL(parsedURL)
    }
}

// MARK: - Previews

#Preview("Detail View") {
    ShortcutDetailView(id: "1c54c02d29b7447e82c67d247b6dc697")
}

#if os(iOS)
@available(iOS 18, *)
#Preview("In Sheet") {
    @Previewable @Namespace var namespace
    @Previewable @State var selectedData: ShortcutData?

    ShortcutTile(id: "1c54c02d29b7447e82c67d247b6dc697") { url, data in
        selectedData = data
    }
    .matchedTransitionSource(id: "shortcutTile", in: namespace)
    .frame(width: 160, height: 110)
    .sheet(item: $selectedData) { data in
        ShortcutDetailView(data: data)
            .navigationTransition(.zoom(sourceID: "shortcutTile", in: namespace))
    }
}
#endif
