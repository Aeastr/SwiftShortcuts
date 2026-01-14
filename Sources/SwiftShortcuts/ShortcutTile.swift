//
//  ShortcutTile.swift
//  SwiftShortcuts
//

import SwiftUI

/// A tile view that displays an Apple Shortcut with its icon, name, and gradient background.
///
/// You can create a tile in three ways:
///
/// 1. **ID-based** - Provide a shortcut ID and the tile fetches all metadata automatically:
/// ```swift
/// ShortcutTile(id: "f00836becd2845109809720d2a70e32f")
/// ```
///
/// 2. **URL-based** - Provide an iCloud share URL and the tile fetches all metadata automatically:
/// ```swift
/// ShortcutTile(url: "https://www.icloud.com/shortcuts/abc123")
/// ```
///
/// 3. **Manual** - Provide the details yourself, use `.foregroundStyle()` for the gradient:
/// ```swift
/// ShortcutTile(name: "My Shortcut", systemImage: "star.fill", url: "https://...")
///     .foregroundStyle(Color.blue.gradient)
/// ```
///
/// By default, tapping the tile opens the shortcut in the Shortcuts app.
/// Provide a custom action to override:
/// ```swift
/// ShortcutTile(id: "abc123") { url, data in
///     // Custom action - data includes icon after loading
/// }
/// ```
public struct ShortcutTile: View {
    @Environment(\.shortcutTileStyle) private var style
    @Environment(\.shortcutLoadingStagger) private var stagger
    @Environment(\.openURL) private var openURL

    // Source of data
    private enum DataSource: Sendable {
        case url(String)
        case manual(name: String, icon: Image?, glyphSymbol: String?, url: String)
        case preloaded(data: ShortcutData)
    }

    private let dataSource: DataSource
    private let action: ((_ url: String, _ data: ShortcutData?) -> Void)?

    private static func iCloudURL(for id: String) -> String {
        "https://www.icloud.com/shortcuts/\(id)"
    }

    // State for URL-based loading
    @State private var loadedData: ShortcutData?
    @State private var isLoading = false

    // MARK: - URL-based Initializers

    /// Creates a shortcut tile that automatically fetches metadata from an iCloud share URL.
    ///
    /// - Parameters:
    ///   - url: The iCloud share URL (e.g., "https://www.icloud.com/shortcuts/abc123")
    ///   - action: Optional custom action when tapped. Receives url and data. Defaults to opening in Shortcuts app.
    public init(url: String, action: ((_ url: String, _ data: ShortcutData?) -> Void)? = nil) {
        self.dataSource = .url(url)
        self.action = action
    }

    /// Creates a shortcut tile that automatically fetches metadata using a shortcut ID.
    ///
    /// - Parameters:
    ///   - id: The shortcut ID (e.g., "f00836becd2845109809720d2a70e32f")
    ///   - action: Optional custom action when tapped. Receives url and data. Defaults to opening in Shortcuts app.
    public init(id: String, action: ((_ url: String, _ data: ShortcutData?) -> Void)? = nil) {
        self.dataSource = .url(Self.iCloudURL(for: id))
        self.action = action
    }

    // MARK: - Manual Initializers

    /// Creates a shortcut tile with manually provided details.
    ///
    /// - Parameters:
    ///   - name: The shortcut's display name
    ///   - image: The shortcut's icon image (optional)
    ///   - url: The iCloud share URL for tap-to-open
    ///   - action: Optional custom action when tapped. Receives url and data. Defaults to opening in Shortcuts app.
    ///
    /// Use `.foregroundStyle()` to set the background gradient:
    /// ```swift
    /// ShortcutTile(name: "My Shortcut", systemImage: "star", url: "...")
    ///     .foregroundStyle(LinearGradient(...))
    /// ```
    public init(
        name: String,
        image: Image? = nil,
        url: String,
        action: ((_ url: String, _ data: ShortcutData?) -> Void)? = nil
    ) {
        self.dataSource = .manual(name: name, icon: image, glyphSymbol: nil, url: url)
        self.action = action
    }

    /// Creates a shortcut tile with a system image icon.
    ///
    /// - Parameters:
    ///   - name: The shortcut's display name
    ///   - systemImage: The SF Symbol name for the icon
    ///   - url: The iCloud share URL for tap-to-open
    ///   - action: Optional custom action when tapped. Receives url and data. Defaults to opening in Shortcuts app.
    ///
    /// Use `.foregroundStyle()` to set the background gradient:
    /// ```swift
    /// ShortcutTile(name: "My Shortcut", systemImage: "star", url: "...")
    ///     .foregroundStyle(LinearGradient(...))
    /// ```
    public init(
        name: String,
        systemImage: String,
        url: String,
        action: ((_ url: String, _ data: ShortcutData?) -> Void)? = nil
    ) {
        self.dataSource = .manual(name: name, icon: nil, glyphSymbol: systemImage, url: url)
        self.action = action
    }

    /// Creates a shortcut tile with manually provided details.
    ///
    /// - Parameters:
    ///   - name: The shortcut's display name
    ///   - image: The shortcut's icon image (optional)
    ///   - id: The shortcut ID (e.g., "f00836becd2845109809720d2a70e32f")
    ///   - action: Optional custom action when tapped. Receives url and data. Defaults to opening in Shortcuts app.
    ///
    /// Use `.foregroundStyle()` to set the background gradient:
    /// ```swift
    /// ShortcutTile(name: "My Shortcut", systemImage: "star", id: "...")
    ///     .foregroundStyle(LinearGradient(...))
    /// ```
    public init(
        name: String,
        image: Image? = nil,
        id: String,
        action: ((_ url: String, _ data: ShortcutData?) -> Void)? = nil
    ) {
        self.dataSource = .manual(name: name, icon: image, glyphSymbol: nil, url: Self.iCloudURL(for: id))
        self.action = action
    }

    /// Creates a shortcut tile with a system image icon.
    ///
    /// - Parameters:
    ///   - name: The shortcut's display name
    ///   - systemImage: The SF Symbol name for the icon
    ///   - id: The shortcut ID (e.g., "f00836becd2845109809720d2a70e32f")
    ///   - action: Optional custom action when tapped. Receives url and data. Defaults to opening in Shortcuts app.
    ///
    /// Use `.foregroundStyle()` to set the background gradient:
    /// ```swift
    /// ShortcutTile(name: "My Shortcut", systemImage: "star", id: "...")
    ///     .foregroundStyle(LinearGradient(...))
    /// ```
    public init(
        name: String,
        systemImage: String,
        id: String,
        action: ((_ url: String, _ data: ShortcutData?) -> Void)? = nil
    ) {
        self.dataSource = .manual(name: name, icon: nil, glyphSymbol: systemImage, url: Self.iCloudURL(for: id))
        self.action = action
    }

    // MARK: - Pre-loaded Initializer

    /// Creates a shortcut tile with pre-loaded data. No fetching will occur.
    ///
    /// Use this initializer when you already have the shortcut data (e.g., from a parent view
    /// that fetched it) to avoid redundant API calls. The icon should be included in the data.
    ///
    /// - Parameters:
    ///   - data: The pre-loaded shortcut data (including icon)
    ///   - action: Optional custom action when tapped. Receives url and data. Defaults to opening in Shortcuts app.
    public init(
        data: ShortcutData,
        action: ((_ url: String, _ data: ShortcutData?) -> Void)? = nil
    ) {
        self.dataSource = .preloaded(data: data)
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        let configuration = makeConfiguration()

        Button {
            performAction(with: configuration)
        } label: {
            Color.clear
        }
        .buttonStyle(TileButtonStyle(baseConfiguration: configuration, style: style))
        .task {
            await loadDataIfNeeded()
        }
    }

    // MARK: - Private Helpers

    private func makeConfiguration() -> ShortcutTileStyleConfiguration {
        switch dataSource {
        case .url(let url):
            return ShortcutTileStyleConfiguration(
                name: loadedData?.name ?? "",
                icon: loadedData?.icon,
                glyphSymbol: loadedData?.glyphSymbol,
                gradient: loadedData?.gradient,
                isLoading: isLoading,
                url: url
            )

        case .manual(let name, let icon, let glyphSymbol, let url):
            return ShortcutTileStyleConfiguration(
                name: name,
                icon: icon,
                glyphSymbol: glyphSymbol,
                gradient: nil,  // Uses .foregroundStyle() from environment
                isLoading: false,
                url: url
            )

        case .preloaded(let data):
            return ShortcutTileStyleConfiguration(
                name: data.name,
                icon: data.icon,
                glyphSymbol: data.glyphSymbol,
                gradient: data.gradient,
                isLoading: false,
                url: data.iCloudLink
            )
        }
    }

    private func performAction(with configuration: ShortcutTileStyleConfiguration) {
        if let action {
            // Get effective data based on data source
            let data: ShortcutData? = switch dataSource {
            case .url:
                loadedData
            case .manual:
                nil
            case .preloaded(let preloadedData):
                preloadedData
            }
            action(configuration.url, data)
        } else {
            openShortcut(url: configuration.url)
        }
    }

    private func openShortcut(url urlString: String) {
        guard let url = URL(string: urlString),
              !url.lastPathComponent.isEmpty,
              let shortcutsURL = URL(string: "shortcuts://open-shortcut?id=\(url.lastPathComponent)") else {
            return
        }
        openURL(shortcutsURL)
    }

    private func loadDataIfNeeded() async {
        // Only load for URL-based data source; manual and preloaded don't need fetching
        guard case .url(let url) = dataSource else { return }

        isLoading = true
        defer { isLoading = false }

        // Stagger requests when displaying multiple tiles
        if let stagger {
            try? await Task.sleep(nanoseconds: UInt64.random(in: stagger))
        }

        do {
            var data = try await ShortcutService.shared.fetchMetadata(from: url)

            // Load icon if available and add it to data
            if let iconURL = data.iconURL {
                let icon = await ShortcutService.shared.fetchIcon(from: iconURL)
                data = data.with(icon: icon)
            }

            loadedData = data
        } catch {
            print("Failed to fetch shortcut metadata: \(error)")
        }
    }
}

// MARK: - Loading Stagger Configuration

/// Controls the stagger delay for shortcut tile loading.
public enum ShortcutLoadingStagger: Sendable {
    /// Disable staggering entirely for immediate loading.
    case disabled
}

private struct ShortcutLoadingStaggerKey: EnvironmentKey {
    static let defaultValue: ClosedRange<UInt64>? = 50_000_000...200_000_000
}

extension EnvironmentValues {
    var shortcutLoadingStagger: ClosedRange<UInt64>? {
        get { self[ShortcutLoadingStaggerKey.self] }
        set { self[ShortcutLoadingStaggerKey.self] = newValue }
    }
}

extension View {
    /// Configures the stagger delay range for shortcut tile loading.
    ///
    /// When displaying multiple tiles, each tile waits a random delay within this range
    /// before fetching metadata. This prevents overwhelming the API with simultaneous requests.
    ///
    /// - Parameter range: The delay range in seconds (e.g., `0.05...0.2`)
    /// - Returns: A view with the stagger configuration applied
    ///
    /// ```swift
    /// ShortcutTile(id: "abc123")
    ///     .shortcutLoadingStagger(0.01...0.05)
    /// ```
    public func shortcutLoadingStagger(_ range: ClosedRange<Double>) -> some View {
        environment(\.shortcutLoadingStagger,
            UInt64(range.lowerBound * 1_000_000_000)...UInt64(range.upperBound * 1_000_000_000)
        )
    }

    /// Disables stagger delay for shortcut tile loading.
    ///
    /// ```swift
    /// ShortcutTile(id: "abc123")
    ///     .shortcutLoadingStagger(.disabled)
    /// ```
    public func shortcutLoadingStagger(_ stagger: ShortcutLoadingStagger) -> some View {
        environment(\.shortcutLoadingStagger, nil)
    }
}

// MARK: - Previews

#Preview("URL-based") {
    ShortcutTile(url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f")
        .frame(width: 160, height: 110)
        .padding()
}

#Preview("ID-based") {
    ShortcutTile(id: "f00836becd2845109809720d2a70e32f")
        .frame(width: 160, height: 110)
        .padding()
}

#Preview("Manual") {
    ShortcutTile(
        name: "My Shortcut",
        image: Image(systemName: "star.fill"),
        url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f"
    )
    .foregroundStyle(ShortcutGradient.blue)
    .frame(width: 160, height: 110)
    .padding()
}

#Preview("Compact Style") {
    VStack {
        ShortcutTile(
            name: "Quick Note",
            systemImage: "note.text",
            url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f"
        )
        .foregroundStyle(ShortcutGradient.orange)
        .shortcutTileStyle(.compact)

        ShortcutTile(
            name: "Timer",
            systemImage: "timer",
            url: "https://www.icloud.com/shortcuts/d598f4dc52d9469f9161b302f1257350"
        )
        .foregroundStyle(ShortcutGradient.teal)
        .shortcutTileStyle(.compact)
    }
    .padding()
}

#Preview("Custom Action") {
    ShortcutTile(
        name: "Custom Action",
        systemImage: "hand.tap",
        url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f"
    ) { url, data in
        print("Custom tap: \(url), data: \(String(describing: data))")
    }
    .foregroundStyle(ShortcutGradient.purple)
    .frame(width: 160, height: 110)
    .padding()
}
