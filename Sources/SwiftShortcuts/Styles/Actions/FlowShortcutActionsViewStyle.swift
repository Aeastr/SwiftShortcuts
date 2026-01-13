//
//  FlowShortcutActionsViewStyle.swift
//  SwiftShortcuts
//

import SwiftUI

/// A flow-style visualization showing actions as connected nodes with control flow indentation.
public struct FlowShortcutActionsViewStyle: ShortcutActionsViewStyle {
    public init() {}

    @MainActor
    public func makeBody(configuration: ShortcutActionsViewStyleConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
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
                // Flow visualization
                FlowContent(actions: configuration.actions, gradient: configuration.gradient)
                    .padding()
            }
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Flow Content

private struct FlowContent: View {
    let actions: [WorkflowAction]
    let gradient: LinearGradient?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(actions.enumerated()), id: \.element.id) { index, action in
                let indentLevel = calculateIndentLevel(upTo: index)
                let isLast = index == actions.count - 1

                FlowNode(
                    action: action,
                    indentLevel: indentLevel,
                    showConnector: !isLast,
                    gradient: gradient
                )
            }
        }
    }

    /// Calculate indent level based on control flow nesting.
    private func calculateIndentLevel(upTo index: Int) -> Int {
        var level = 0
        for i in 0..<index {
            let action = actions[i]
            if let mode = action.controlFlowMode {
                switch mode {
                case .start:
                    level += 1
                case .middle:
                    // Stay at same level (already decremented, now increment back)
                    break
                case .end:
                    level = max(0, level - 1)
                }
            }
        }

        // Adjust for current action
        if let mode = actions[index].controlFlowMode {
            switch mode {
            case .start:
                break // Will indent children, not self
            case .middle, .end:
                level = max(0, level - 1)
            }
        }

        return level
    }
}

// MARK: - Flow Node

private struct FlowNode: View {
    let action: WorkflowAction
    let indentLevel: Int
    let showConnector: Bool
    let gradient: LinearGradient?

    private var nodeHeight: CGFloat {
        action.subtitle != nil ? 56 : 44
    }
    private let connectorHeight: CGFloat = 16
    private let indentWidth: CGFloat = 24

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Indent spacing
            if indentLevel > 0 {
                HStack(spacing: 0) {
                    ForEach(0..<indentLevel, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(width: 2)
                            .padding(.horizontal, (indentWidth - 2) / 2)
                    }
                }
                .frame(height: nodeHeight + (showConnector ? connectorHeight : 0))
            }

            // Node and connector
            VStack(spacing: 0) {
                // Action node
                HStack(alignment: .center, spacing: 10) {
                    // Icon
                    ZStack {
                        if action.isControlFlowMarker {
                            Circle()
                                .strokeBorder(Color.secondary.opacity(0.5), lineWidth: 1.5)
                                .frame(width: 32, height: 32)
                        } else {
                            Circle()
                                .fill(nodeGradient)
                                .frame(width: 32, height: 32)
                        }

                        Image(systemName: action.systemImage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(action.isControlFlowMarker ? .secondary : .white)
                    }

                    // Name and subtitle
                    VStack(alignment: .leading, spacing: 2) {
                        Text(action.displayName)
                            .font(.subheadline)
                            .foregroundStyle(action.isControlFlowMarker ? .secondary : .primary)

                        if let subtitle = action.subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()
                }
                .frame(height: nodeHeight)

                // Connector line
                if showConnector {
                    HStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 2, height: connectorHeight)
                            .offset(x: 15) // Center under the node icon
                        Spacer()
                    }
                }
            }
        }
    }

    private var nodeGradient: LinearGradient {
        gradient ?? LinearGradient(
            colors: [.gray],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Style Extension

extension ShortcutActionsViewStyle where Self == FlowShortcutActionsViewStyle {
    /// A flow-style visualization with connected nodes and control flow indentation.
    public static var flow: FlowShortcutActionsViewStyle { FlowShortcutActionsViewStyle() }
}

// MARK: - Preview

#Preview("Flow Style") {
    ScrollView{
        ShortcutActionsView(url: "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f")
            .shortcutActionsViewStyle(.flow)
            .padding()
    }
}
