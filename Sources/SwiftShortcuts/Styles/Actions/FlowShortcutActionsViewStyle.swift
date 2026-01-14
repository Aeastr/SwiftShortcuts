//
//  FlowShortcutActionsViewStyle.swift
//  SwiftShortcuts
//

import SwiftUI

/// A flow-style visualization showing actions as connected nodes with control flow indentation.
public struct FlowShortcutActionsViewStyle: ShortcutActionsViewStyle {
    public init() {}

    private let nodeSize: CGFloat = 32
    private let connectorHeight: CGFloat = 16
    private let indentWidth: CGFloat = 24

    // MARK: - Body

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
                makeActionList(configuration: configuration)
                    .padding()
            }
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Node (Protocol Override)

    @MainActor
    public func makeNode(action: WorkflowAction, gradient: LinearGradient?) -> some View {
        HStack(alignment: .center, spacing: 10) {
            // Icon circle
            ZStack {
                if action.isControlFlowMarker {
                    Circle()
                        .strokeBorder(Color.secondary.opacity(0.5), lineWidth: 1.5)
                        .frame(width: nodeSize, height: nodeSize)
                } else {
                    Circle()
                        .fill(gradient ?? LinearGradient(colors: [.gray], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: nodeSize, height: nodeSize)
                }

                Image(systemName: action.systemImage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(action.isControlFlowMarker ? .secondary : .white)
            }

            // Labels
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
    }

    // MARK: - Action List

    @MainActor @ViewBuilder
    private func makeActionList(configuration: ShortcutActionsViewStyleConfiguration) -> some View {
        let actions = configuration.actions

        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(actions.enumerated()), id: \.element.id) { index, action in
                let indentLevel = calculateIndentLevel(actions: actions, upTo: index)
                let isLast = index == actions.count - 1
                let nextIndentLevel = isLast ? indentLevel : calculateIndentLevel(actions: actions, upTo: index + 1)
                let indentChange = nextIndentLevel - indentLevel  // positive = deeper, negative = shallower

                makeFlowNode(
                    action: action,
                    indentLevel: indentLevel,
                    showConnector: !isLast,
                    indentChange: indentChange,
                    gradient: configuration.gradient
                )
            }
        }
    }

    // MARK: - Flow Node (with indentation)

    @MainActor @ViewBuilder
    private func makeFlowNode(
        action: WorkflowAction,
        indentLevel: Int,
        showConnector: Bool,
        indentChange: Int,
        gradient: LinearGradient?
    ) -> some View {
        let nodeHeight: CGFloat = action.subtitle != nil ? 56 : 44

        VStack(spacing: 0) {
            makeNode(action: action, gradient: gradient)
                .frame(height: nodeHeight)

            if showConnector {
                makeConnector(indentChange: indentChange)
            }
        }
        .padding(.leading, CGFloat(indentLevel) * indentWidth)
    }

    // MARK: - Connector

    @MainActor @ViewBuilder
    private func makeConnector(indentChange: Int) -> some View {
        HStack {
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 2, height: connectorHeight)
                .mask(connectorMask(indentChange: indentChange))
                .offset(x: (nodeSize / 2) - 1)
            Spacer()
        }
    }

    private func connectorMask(indentChange: Int) -> some View {
        Group {
            if indentChange > 0 {
                // Going deeper: fade out at bottom
                LinearGradient(
                    colors: [.white, .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else if indentChange < 0 {
                // Going shallower: hidden
                Color.clear
            } else {
                // Same level: solid
                Color.white
            }
        }
    }

    // MARK: - Indent Calculation

    private func calculateIndentLevel(actions: [WorkflowAction], upTo index: Int) -> Int {
        var level = 0
        for i in 0..<index {
            if let mode = actions[i].controlFlowMode {
                switch mode {
                case .start: level += 1
                case .middle: break
                case .end: level = max(0, level - 1)
                }
            }
        }

        if let mode = actions[index].controlFlowMode {
            switch mode {
            case .start: break
            case .middle, .end: level = max(0, level - 1)
            }
        }

        return level
    }
}

// MARK: - Style Extension

extension ShortcutActionsViewStyle where Self == FlowShortcutActionsViewStyle {
    /// A flow-style visualization with connected nodes and control flow indentation.
    public static var flow: FlowShortcutActionsViewStyle { FlowShortcutActionsViewStyle() }
}

// MARK: - Preview

#Preview("Flow Style") {
    ScrollView {
        ShortcutActionsView(url: "https://www.icloud.com/shortcuts/fdc7508d385b4755a00e9b394cf52ae1")
            .shortcutActionsViewStyle(.flow)
            .padding()
        
            ShortcutActionsView(url: "https://www.icloud.com/shortcuts/81e9938dabdc447094e03b09fc008d31")
                .shortcutActionsViewStyle(.flow)
                .padding()
    }
}


