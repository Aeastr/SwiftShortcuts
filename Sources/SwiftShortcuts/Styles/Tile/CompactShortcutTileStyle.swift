//
//  CompactShortcutTileStyle.swift
//  SwiftShortcuts
//

import SwiftUI

/// A compact shortcut tile style for list-like layouts
public struct CompactShortcutTileStyle: ShortcutTileStyle {
    public init() {}

    @MainActor
    public func makeBody(configuration: ShortcutTileStyleConfiguration) -> some View {
        HStack(spacing: 12) {
            // Icon (SF Symbol is primary, pre-rendered image is fallback)
            Group {
                if let icon = configuration.icon {
                    Image(systemName: icon)
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
                } else if let image = configuration.image {
                    image
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
        // Press feedback
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        .opacity(configuration.isPressed ? 0.9 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Style Extension

extension ShortcutTileStyle where Self == CompactShortcutTileStyle {
    /// A compact tile style for list-like layouts
    public static var compact: CompactShortcutTileStyle { CompactShortcutTileStyle() }
}

// MARK: - Preview

#Preview("Compact Style") {
    VStack(spacing: 12) {
        ShortcutTile(id: "f00836becd2845109809720d2a70e32f")
            .shortcutTileStyle(.compact)

        ShortcutTile(id: "1c54c02d29b7447e82c67d247b6dc697")
            .shortcutTileStyle(.compact)
    }
    .padding()
}
