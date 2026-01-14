//
//  ShortcutCard.swift
//  SwiftShortcuts
//

import SwiftUI

/// A card view that displays an Apple Shortcut with its icon, name, and gradient background.
///
/// You can create a card in three ways:
///
/// 1. **ID-based** - Provide a shortcut ID and the card fetches all metadata automatically:
/// ```swift
/// ShortcutCard(id: "f00836becd2845109809720d2a70e32f")
/// ```
///
/// 2. **URL-based** - Provide an iCloud share URL and the card fetches all metadata automatically:
/// ```swift
/// ShortcutCard(url: "https://www.icloud.com/shortcuts/abc123")
/// ```
///
/// 3. **Manual** - Provide the details yourself, use `.foregroundStyle()` for the gradient:
/// ```swift
/// ShortcutCard(name: "My Shortcut", systemImage: "star.fill", url: "https://...")
///     .foregroundStyle(Color.blue.gradient)
/// ```
///
/// Tapping the card opens the shortcut in the Shortcuts app.
public struct ShortcutCard: View {
    @Environment(\.shortcutCardStyle) private var style
    @Environment(\.shortcutLoadingStagger) private var stagger

    // Source of data
    private enum DataSource: Sendable {
        case url(String)
        case manual(name: String, icon: Image?, glyphSymbol: String?, url: String)
    }

    private let dataSource: DataSource

    // State for URL-based loading
    @State private var loadedData: ShortcutData?
    @State private var loadedIcon: Image?
    @State private var isLoading = false

    // MARK: - URL-based Initializers

    /// Creates a shortcut card that automatically fetches metadata from an iCloud share URL.
    ///
    /// - Parameter url: The iCloud share URL (e.g., "https://www.icloud.com/shortcuts/abc123")
    public init(url: String) {
        self.dataSource = .url(url)
    }

    /// Creates a shortcut card that automatically fetches metadata using a shortcut ID.
    ///
    /// - Parameter id: The shortcut ID (e.g., "f00836becd2845109809720d2a70e32f")
    public init(id: String) {
        self.dataSource = .url("https://www.icloud.com/shortcuts/\(id)")
    }

    // MARK: - Manual Initializers

    /// Creates a shortcut card with manually provided details.
    ///
    /// - Parameters:
    ///   - name: The shortcut's display name
    ///   - image: The shortcut's icon image (optional)
    ///   - url: The iCloud share URL for tap-to-open
    ///
    /// Use `.foregroundStyle()` to set the background gradient:
    /// ```swift
    /// ShortcutCard(name: "My Shortcut", systemImage: "star", url: "...")
    ///     .foregroundStyle(LinearGradient(...))
    /// ```
    public init(
        name: String,
        image: Image? = nil,
        url: String
    ) {
        self.dataSource = .manual(name: name, icon: image, glyphSymbol: nil, url: url)
    }

    /// Creates a shortcut card with a system image icon.
    ///
    /// - Parameters:
    ///   - name: The shortcut's display name
    ///   - systemImage: The SF Symbol name for the icon
    ///   - url: The iCloud share URL for tap-to-open
    ///
    /// Use `.foregroundStyle()` to set the background gradient:
    /// ```swift
    /// ShortcutCard(name: "My Shortcut", systemImage: "star", url: "...")
    ///     .foregroundStyle(LinearGradient(...))
    /// ```
    public init(
        name: String,
        systemImage: String,
        url: String
    ) {
        self.dataSource = .manual(name: name, icon: nil, glyphSymbol: systemImage, url: url)
    }

    // MARK: - Body

    public var body: some View {
        let configuration = makeConfiguration()
        AnyView(style.makeBody(configuration: configuration))
            .task {
                await loadDataIfNeeded()
            }
    }

    // MARK: - Private Helpers

    private func makeConfiguration() -> ShortcutCardStyleConfiguration {
        switch dataSource {
        case .url(let url):
            return ShortcutCardStyleConfiguration(
                name: loadedData?.name ?? "",
                icon: loadedIcon,
                glyphSymbol: loadedData?.glyphSymbol,
                gradient: loadedData?.gradient,
                isLoading: isLoading,
                url: url
            )

        case .manual(let name, let icon, let glyphSymbol, let url):
            return ShortcutCardStyleConfiguration(
                name: name,
                icon: icon,
                glyphSymbol: glyphSymbol,
                gradient: nil,  // Uses .foregroundStyle() from environment
                isLoading: false,
                url: url
            )
        }
    }

    private func loadDataIfNeeded() async {
        guard case .url(let url) = dataSource else { return }

        isLoading = true
        defer { isLoading = false }

        // Stagger requests when displaying multiple cards
        if let stagger {
            try? await Task.sleep(nanoseconds: UInt64.random(in: stagger))
        }

        do {
            let data = try await ShortcutService.shared.fetchMetadata(from: url)
            loadedData = data

            // Load icon if available
            if let iconURL = data.iconURL {
                loadedIcon = await ShortcutService.shared.fetchIcon(from: iconURL)
            }
        } catch {
            print("Failed to fetch shortcut metadata: \(error)")
        }
    }
}

// MARK: - Style Modifier

extension View {
    /// Applies a custom style to shortcut cards within this view hierarchy.
    ///
    /// - Parameter style: The style to apply
    /// - Returns: A view with the style applied
    public func shortcutCardStyle(_ style: some ShortcutCardStyle) -> some View {
        environment(\.shortcutCardStyle, style)
    }
}

// MARK: - Loading Stagger Configuration

/// Controls the stagger delay for shortcut card loading.
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
    /// Configures the stagger delay range for shortcut card loading.
    ///
    /// When displaying multiple cards, each card waits a random delay within this range
    /// before fetching metadata. This prevents overwhelming the API with simultaneous requests.
    ///
    /// - Parameter range: The delay range in seconds (e.g., `0.05...0.2`)
    /// - Returns: A view with the stagger configuration applied
    ///
    /// ```swift
    /// ShortcutCard(id: "abc123")
    ///     .shortcutLoadingStagger(0.01...0.05)
    /// ```
    public func shortcutLoadingStagger(_ range: ClosedRange<Double>) -> some View {
        environment(\.shortcutLoadingStagger,
            UInt64(range.lowerBound * 1_000_000_000)...UInt64(range.upperBound * 1_000_000_000)
        )
    }

    /// Disables stagger delay for shortcut card loading.
    ///
    /// ```swift
    /// ShortcutCard(id: "abc123")
    ///     .shortcutLoadingStagger(.disabled)
    /// ```
    public func shortcutLoadingStagger(_ stagger: ShortcutLoadingStagger) -> some View {
        environment(\.shortcutLoadingStagger, nil)
    }
}

// MARK: - Previews

#Preview("URL-based") {
    ShortcutCard(url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f")
        .frame(width: 160, height: 110)
        .padding()
}

#Preview("ID-based") {
    ShortcutCard(id: "f00836becd2845109809720d2a70e32f")
        .frame(width: 160, height: 110)
        .padding()
}

#Preview("Manual") {
    ShortcutCard(
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
        ShortcutCard(
            name: "Quick Note",
            systemImage: "note.text",
            url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f"
        )
        .foregroundStyle(ShortcutGradient.orange)
        .shortcutCardStyle(.compact)

        ShortcutCard(
            name: "Timer",
            systemImage: "timer",
            url: "https://www.icloud.com/shortcuts/d598f4dc52d9469f9161b302f1257350"
        )
        .foregroundStyle(ShortcutGradient.teal)
        .shortcutCardStyle(.compact)
    }
    .padding()
}

