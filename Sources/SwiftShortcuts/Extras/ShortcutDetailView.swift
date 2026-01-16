//
//  ShortcutDetailView.swift
//  SwiftShortcuts
//

import SwiftUI
import Conditionals

/// A detail view for displaying shortcut information in a sheet.
///
/// Shows the shortcut tile with a summary of metadata (action count, creation date)
/// and an "Add Shortcut" button. Typically presented as a sheet when tapping a `ShortcutTile`.
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
/// ShortcutDetailView(data: shortcutData)
/// ```
///
/// For a more detailed view with full workflow actions visualization, see
/// `ShortcutDetailedView` in the Extras folder.
public struct ShortcutDetailView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @Environment(\.shortcutErrorHandler) private var errorHandler

    // Source of data
    private enum DataSource {
        case url(String)
        case preloaded(data: ShortcutData)
    }

    private let dataSource: DataSource

    @State private var shortcutData: ShortcutData?
    @State private var isLoading = false
    @State private var error: ShortcutError?

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

    /// Creates a shortcut detail view with pre-loaded metadata.
    ///
    /// Use this when you already have the shortcut data from a tile tap.
    /// Action count will be fetched if not already present in the data.
    ///
    /// - Parameter data: The pre-loaded shortcut data
    public init(data: ShortcutData) {
        self.dataSource = .preloaded(data: data)
        self._shortcutData = State(initialValue: data)
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
                    VStack(spacing: 20) {
                        Spacer()

                        // Shortcut tile
                        ShortcutTile(data: data)
                            .frame(height: 110)
                            .frame(maxWidth: 180)
                            .disabled(true)

                        // Summary line
                        if isLoading {
                            ProgressView()
                                .padding(.top, 8)
                        } else {
                            ShortcutSummaryRow(data: data)
                        }

                        Spacer()
                    }
                    .padding()
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
            await loadMetadata(from: url)

        case .preloaded(let data):
            // Fetch action count if not already present
            if data.actionCount == nil {
                await loadActionCount(shortcutURL: data.shortcutURL)
            }
        }
    }

    private func loadMetadata(from url: String) async {
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

            // Fetch action count
            if let shortcutURL = data.shortcutURL {
                let count = try await ShortcutService.shared.fetchActionCount(from: shortcutURL)
                data = data.with(actionCount: count)
            }

            shortcutData = data
        } catch let shortcutError as ShortcutError {
            handleError(shortcutError, url: url)
        } catch {
            handleError(.metadataFetchFailed(url: url, underlying: error), url: url)
        }
    }

    private func loadActionCount(shortcutURL: String?) async {
        guard let shortcutURL else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let count = try await ShortcutService.shared.fetchActionCount(from: shortcutURL)
            shortcutData = shortcutData?.with(actionCount: count)
        } catch {
            // Action count fetch failed - not critical, just won't show count
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

// MARK: - Summary Row

/// A row displaying shortcut metadata summary (action count, creation date, signing status)
private struct ShortcutSummaryRow: View {
    let data: ShortcutData

    private var formatter: RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }

    private var formattedCreatedDate: String? {
        guard let date = data.createdAt else { return nil }
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private var formattedModifiedDate: String? {
        guard let modified = data.modifiedAt,
              let created = data.createdAt,
              !Calendar.current.isDate(modified, equalTo: created, toGranularity: .minute) else {
            return nil
        }
        return formatter.localizedString(for: modified, relativeTo: Date())
    }

    var body: some View {
        HStack(spacing: 6) {
            // Signing status indicator
            if data.isApproved {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            }

            // Action count
            if let count = data.actionCount {
                Text("\(count) action\(count == 1 ? "" : "s")")
            }

            // Creation date
            if let dateString = formattedCreatedDate {
                if data.actionCount != nil {
                    Text("•")
                        .foregroundStyle(.tertiary)
                }
                Text("Created \(dateString)")
            }

            // Modified date (only if different from created)
            if let modifiedString = formattedModifiedDate {
                Text("•")
                    .foregroundStyle(.tertiary)
                Text("Modified \(modifiedString)")
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
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
