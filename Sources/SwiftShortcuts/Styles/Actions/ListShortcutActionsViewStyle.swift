//
//  ListShortcutActionsViewStyle.swift
//  SwiftShortcuts
//

import SwiftUI

/// A simple list style for displaying shortcut actions as numbered rows.
public struct ListShortcutActionsViewStyle: ShortcutActionsViewStyle {
    public init() {}

    @MainActor
    public func makeBody(configuration: ShortcutActionsViewStyleConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if !configuration.shortcutName.isEmpty {
                makeHeader(configuration: configuration)
                Divider()
            }

            if configuration.isLoading {
                makeLoadingState()
            } else if configuration.actions.isEmpty {
                makeEmptyState()
            } else {
                ForEach(Array(configuration.actions.enumerated()), id: \.element.id) { index, action in
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(width: 20, alignment: .trailing)

                        makeNode(action: action, gradient: configuration.gradient)
                    }

                    if index < configuration.actions.count - 1 {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Style Extension

extension ShortcutActionsViewStyle where Self == ListShortcutActionsViewStyle {
    /// A simple list style showing numbered action rows.
    public static var list: ListShortcutActionsViewStyle { ListShortcutActionsViewStyle() }
}

// MARK: - Preview

#Preview("List Style") {
    ScrollView {
        ShortcutActionsView(url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f")
            .shortcutActionsViewStyle(.list)
            .padding()
    }
}
