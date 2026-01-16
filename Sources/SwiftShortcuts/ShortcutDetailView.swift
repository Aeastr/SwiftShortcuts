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
    @Environment(\.shortcutErrorHandler) private var errorHandler

    // Source of data
    private enum DataSource {
        case url(String)
        case partial(data: ShortcutData)  // Has metadata, needs actions
        case complete(data: ShortcutData, actions: [WorkflowAction])  // All data provided
    }

    private let dataSource: DataSource

    @State private var shortcutData: ShortcutData?
    @State private var fetchedActions: [WorkflowAction] = []
    @State private var isLoading = false
    @State private var error: ShortcutError?

    private var effectiveActions: [WorkflowAction] {
        switch dataSource {
        case .url, .partial:
            return fetchedActions
        case .complete(_, let actions):
            return actions
        }
    }

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

    // MARK: - Pre-loaded Initializers

    /// Creates a shortcut detail view with pre-loaded metadata. Fetches actions only.
    ///
    /// Use this when you already have the shortcut data from a tile tap.
    ///
    /// - Parameter data: The pre-loaded shortcut data
    public init(data: ShortcutData) {
        self.dataSource = .partial(data: data)
        self._shortcutData = State(initialValue: data)
    }

    /// Creates a shortcut detail view with fully pre-loaded data. No fetching will occur.
    ///
    /// Use this when you already have all the data to avoid redundant API calls.
    ///
    /// - Parameters:
    ///   - data: The pre-loaded shortcut data
    ///   - actions: The pre-loaded workflow actions
    public init(data: ShortcutData, actions: [WorkflowAction]) {
        self.dataSource = .complete(data: data, actions: actions)
        self._shortcutData = State(initialValue: data)
        self._fetchedActions = State(initialValue: actions)
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack {
            Group {
                if let error, shortcutData == nil {
                    // Error state when we couldn't load data
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)

                        Text(error.errorDescription ?? "Failed to load shortcut")
                            .font(.headline)

                        if let reason = error.failureReason {
                            Text(reason)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let data = shortcutData {
                    ScrollView {
                        // Pass pre-loaded data to children - NO redundant fetching
                        ShortcutTile(data: data)
                            .frame(height: 110)
                            .frame(maxWidth: 180)
                            .disabled(true)

                        if isLoading {
                            ProgressView()
                                .padding(.top, 40)
                        } else {
                            ShortcutActionsView(data: data, actions: effectiveActions)
                                .shortcutActionsViewStyle(.flow)
                                .padding()
                        }
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
                fetchedActions = try await ShortcutService.shared.fetchWorkflowActions(from: shortcutURL)
            }
        } catch let shortcutError as ShortcutError {
            handleError(shortcutError, url: url)
        } catch {
            handleError(.metadataFetchFailed(url: url, underlying: error), url: url)
        }
    }

    private func loadActionsOnly(shortcutURL: String?) async {
        guard let shortcutURL else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            fetchedActions = try await ShortcutService.shared.fetchWorkflowActions(from: shortcutURL)
        } catch let shortcutError as ShortcutError {
            handleError(shortcutError, url: shortcutURL)
        } catch {
            handleError(.actionsFetchFailed(url: shortcutURL, underlying: error), url: shortcutURL)
        }
    }

    private func handleError(_ shortcutError: ShortcutError, url: String) {
        if let errorHandler {
            errorHandler(error: shortcutError, context: ShortcutErrorContext(source: .detail, url: url))
        } else {
            error = shortcutError
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
    ShortcutDetailView(id: "6256bc4845dd46d6b04b3e9fdd2ad83d")
}

#if os(iOS)
@available(iOS 18, *)
#Preview("In Sheet") {
    @Previewable @Namespace var namespace
    @Previewable @State var selectedData: ShortcutData?

    ShortcutTile(id: "6256bc4845dd46d6b04b3e9fdd2ad83d") { url, data in
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
