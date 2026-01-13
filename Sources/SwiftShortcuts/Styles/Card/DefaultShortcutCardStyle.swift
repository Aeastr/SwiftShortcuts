//
//  DefaultShortcutCardStyle.swift
//  SwiftShortcuts
//

import SwiftUI

/// The default shortcut card style matching Apple's Shortcuts app
public struct DefaultShortcutCardStyle: ShortcutCardStyle {
    public init() {}

    @MainActor
    public func makeBody(configuration: ShortcutCardStyleConfiguration) -> some View {
        CardButton(configuration: configuration) {
            VStack(alignment: .leading, spacing: 5) {
                // Icon in top-left
                Group {
                    if let icon = configuration.icon {
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

                
                Group{
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
        }
    }
}

// MARK: - Style Extension

extension ShortcutCardStyle where Self == DefaultShortcutCardStyle {
    /// The default card style matching Apple's Shortcuts app
    public static var `default`: DefaultShortcutCardStyle { DefaultShortcutCardStyle() }
}

// MARK: - Preview

#Preview("Default Style") {
    VStack(spacing: 20) {
        ShortcutCard(
            name: "Morning Routine",
            systemImage: "sun.horizon.fill",
            url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f"
        )
        .foregroundStyle(ShortcutGradient.orange)
        .frame(width: 160, height: 110)

        ShortcutCard(
            name: "Quick Note",
            systemImage: "note.text",
            url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f"
        )
        .foregroundStyle(ShortcutGradient.blue)
        .frame(width: 160, height: 110)

        ShortcutCard(
            name: "Start Timer",
            systemImage: "timer",
            url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f"
        )
        .foregroundStyle(ShortcutGradient.green)
        .frame(width: 160, height: 110)
    }
    .padding()
}
