//
//  CompactShortcutCardStyle.swift
//  SwiftShortcuts
//

import SwiftUI

/// A compact shortcut card style for list-like layouts
public struct CompactShortcutCardStyle: ShortcutCardStyle {
    public init() {}

    @MainActor
    public func makeBody(configuration: ShortcutCardStyleConfiguration) -> some View {
        CardButton(configuration: configuration) {
            HStack(spacing: 12) {
                // Icon (glyph SF Symbol is primary, API image is fallback)
                Group {
                    if let glyphSymbol = configuration.glyphSymbol {
                        Image(systemName: glyphSymbol)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .padding(8)
                            .background {
                                if let gradient = configuration.gradient {
                                    RoundedRectangle(cornerRadius: 8).fill(gradient)
                                } else {
                                    RoundedRectangle(cornerRadius: 8).fill(.primary)
                                }
                            }
                    } else if let icon = configuration.icon {
                        icon
                            .resizable()
                            .scaledToFit()
                    } else if let gradient = configuration.gradient {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(gradient)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.primary)
                    }
                }
                .frame(width: 44, height: 44)
                .clipShape(.rect(cornerRadius: 10))

                // Name
                if configuration.isLoading {
                    ProgressView()
                } else {
                    Text(configuration.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(12)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

// MARK: - Style Extension

extension ShortcutCardStyle where Self == CompactShortcutCardStyle {
    /// A compact card style for list-like layouts
    public static var compact: CompactShortcutCardStyle { CompactShortcutCardStyle() }
}

// MARK: - Preview

#Preview("Compact Style") {
    VStack(spacing: 12) {
        ShortcutCard(
            name: "Morning Routine",
            systemImage: "sun.horizon.fill",
            url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f"
        )
        .foregroundStyle(ShortcutGradient.orange)
        .shortcutCardStyle(.compact)

        ShortcutCard(
            name: "Quick Note",
            systemImage: "note.text",
            url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f"
        )
        .foregroundStyle(ShortcutGradient.blue)
        .shortcutCardStyle(.compact)

        ShortcutCard(
            name: "Start Timer",
            systemImage: "timer",
            url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f"
        )
        .foregroundStyle(ShortcutGradient.green)
        .shortcutCardStyle(.compact)

        ShortcutCard(
            name: "Play Music",
            systemImage: "music.note",
            url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f"
        )
        .shortcutCardStyle(.compact)
    }
    .padding()
}
