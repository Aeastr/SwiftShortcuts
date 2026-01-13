//
//  DefaultShortcutActionsViewStyle.swift
//  SwiftShortcuts
//

import SwiftUI

/// The default style for displaying shortcut actions as a vertical list.
public struct DefaultShortcutActionsViewStyle: ShortcutActionsViewStyle {
    public init() {}

    @MainActor
    public func makeBody(configuration: ShortcutActionsViewStyleConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with shortcut name
            if !configuration.shortcutName.isEmpty {
                HStack {
                    if let gradient = configuration.gradient {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(gradient)
                            .frame(width: 24, height: 24)
                    }

                    Text(configuration.shortcutName)
                        .font(.headline)

                    Spacer()

                    Text("\(configuration.actions.count) actions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()

                Divider()
            }

            if configuration.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            } else if configuration.actions.isEmpty {
                HStack {
                    Spacer()
                    Text("No actions")
                        .foregroundStyle(.secondary)
                        .padding()
                    Spacer()
                }
            } else {
                // Action list
                ForEach(Array(configuration.actions.enumerated()), id: \.element.id) { index, action in
                    ActionRow(action: action, index: index + 1)

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

// MARK: - Action Row

private struct ActionRow: View {
    let action: WorkflowAction
    let index: Int

    var body: some View {
        HStack(spacing: 12) {
            // Step number
            Text("\(index)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .trailing)

            // Action icon
            Image(systemName: action.systemImage)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            // Action name
            Text(action.displayName)
                .font(.subheadline)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

// MARK: - Style Extension

extension ShortcutActionsViewStyle where Self == DefaultShortcutActionsViewStyle {
    /// The default actions view style showing a vertical list.
    public static var `default`: DefaultShortcutActionsViewStyle { DefaultShortcutActionsViewStyle() }
}

// MARK: - Preview

#Preview("Default Style") {
    VStack(spacing: 20) {
        // Simulated loaded state
        DefaultShortcutActionsViewStyle()
            .makeBody(configuration: ShortcutActionsViewStyleConfiguration(
                shortcutName: "Create Meeting Note",
                actions: [
                    WorkflowAction(identifier: "is.workflow.actions.getupcomingcalendarevents"),
                    WorkflowAction(identifier: "is.workflow.actions.filter.notes"),
                    WorkflowAction(identifier: "is.workflow.actions.conditional"),
                    WorkflowAction(identifier: "is.workflow.actions.createnote"),
                    WorkflowAction(identifier: "is.workflow.actions.shownote"),
                    WorkflowAction(identifier: "is.workflow.actions.alert"),
                ],
                gradient: ShortcutGradient.yellow,
                isLoading: false
            ))

        // Loading state
        DefaultShortcutActionsViewStyle()
            .makeBody(configuration: ShortcutActionsViewStyleConfiguration(
                shortcutName: "Loading Shortcut",
                actions: [],
                gradient: ShortcutGradient.blue,
                isLoading: true
            ))
    }
    .padding()
}
