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
            // Icon in top-left (SF Symbol is primary, pre-rendered image is fallback)
            Group {
                if let icon = configuration.icon {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                } else if let image = configuration.image {
                    image
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
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
            ShortcutTile(url: "https://www.icloud.com/shortcuts/63c3c8a85a2245cf86def8258c58de87")
                .frame(height: 110)

            ShortcutTile(url: "https://www.icloud.com/shortcuts/ede7f60d1aaa48f6b71be479a9ebe673")
                .frame(height: 110)

            ShortcutTile(url: "https://www.icloud.com/shortcuts/0a42a603952b433bbc5d4ae5c78f2995")
                .frame(height: 110)
        }
        .padding()
    }
}
