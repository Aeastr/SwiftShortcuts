//
//  DefaultShortcutTileStyle.swift
//  SwiftShortcuts
//

import SwiftUI

/// The default shortcut tile style matching Apple's Shortcuts app
public struct DefaultShortcutTileStyle: ShortcutTileStyle {
    public init() {}

    @MainActor
    public func makeBody(configuration: ShortcutTileStyleConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            // Icon in top-left (glyph SF Symbol is primary, API image is fallback)
            Group {
                if let glyphSymbol = configuration.glyphSymbol {
                    Image(systemName: glyphSymbol)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                } else if let icon = configuration.icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                } else {
                    Color.clear
                }
            }
            .frame(width: 25, height: 25)
            .clipShape(.rect(cornerRadius: 6))

            Group {
                // Shortcut name at bottom
                if configuration.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(configuration.name)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .padding(14)
        .background {
            if let gradient = configuration.gradient {
                RoundedRectangle(cornerRadius: 20).fill(gradient)
            } else {
                RoundedRectangle(cornerRadius: 20).fill(.primary)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        // Press feedback
        .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
        .opacity(configuration.isPressed ? 0.9 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Style Extension

extension ShortcutTileStyle where Self == DefaultShortcutTileStyle {
    /// The default tile style matching Apple's Shortcuts app
    public static var `default`: DefaultShortcutTileStyle { DefaultShortcutTileStyle() }
}

// MARK: - Preview

#Preview("Default Style") {
    VStack(spacing: 20) {
        ShortcutTile(url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f")
            .frame(width: 160, height: 110)

        ShortcutTile(url: "https://www.icloud.com/shortcuts/59c0216a670f4b98ae36e092aab87cdf")
            .frame(width: 160, height: 110)

        ShortcutTile(url: "https://www.icloud.com/shortcuts/ab1317716ca7490b8536134367b7ba39")
            .frame(width: 160, height: 110)
    }
    .padding()
}
