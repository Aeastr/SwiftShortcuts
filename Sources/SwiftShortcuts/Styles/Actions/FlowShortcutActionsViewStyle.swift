//
//  FlowShortcutActionsViewStyle.swift
//  SwiftShortcuts
//

import SwiftUI

/// The default block-style visualization matching Apple's Shortcuts app.
///
/// Each action appears as its own rounded card with a colored icon badge.
/// Control flow (Repeat, If, Menu) uses indentation to show nesting.
public struct FlowShortcutActionsViewStyle: ShortcutActionsViewStyle {
    public init() {}
    
    private let indentWidth: CGFloat = 20
    
    // MARK: - Body
    
    @MainActor
    public func makeBody(configuration: ShortcutActionsViewStyleConfiguration) -> some View {
        if configuration.isLoading {
            makeLoadingState()
        } else if configuration.actions.isEmpty {
            makeEmptyState()
        } else {
            VStack(spacing: 8) {
                ForEach(Array(configuration.actions.enumerated()), id: \.element.id) { index, action in
                    let indentLevel = calculateIndentLevel(actions: configuration.actions, upTo: index)
                    
                    // Skip end markers
                    if action.controlFlowMode != .end {
                        ActionBlockView(action: action, gradient: configuration.gradient)
                            .padding(.leading, CGFloat(indentLevel) * indentWidth)
                    }
                }
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
        
        // Middle markers (Otherwise, Menu Item) stay at parent's indent level
        if let mode = actions[index].controlFlowMode {
            switch mode {
            case .start: break
            case .middle, .end: level = max(0, level - 1)
            }
        }
        
        return level
    }
}

// MARK: - Action Block View

private struct ActionBlockView: View {
    let action: WorkflowAction
    let gradient: LinearGradient?
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon badge
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(gradient ?? ShortcutGradient.gray)
                
                
                .frame(width: 20, height: 20)
                
                Image(systemName: action.systemImage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // Action name and subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(action.displayName)
                    .font(.body)
                    .fontWeight(.medium)
                
                if let subtitle = action.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(gradient ?? ShortcutGradient.gray)
                        .opacity(0.8)
                }
            }
            
            Spacer()
        }
        .padding(.leading, 14)
        .padding(.trailing, 7)
        .padding(.vertical, 8)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26))
    }
}

// MARK: - Style Extension

extension ShortcutActionsViewStyle where Self == FlowShortcutActionsViewStyle {
    /// The default block-style visualization matching Apple's Shortcuts app.
    public static var flow: FlowShortcutActionsViewStyle { FlowShortcutActionsViewStyle() }
}

// MARK: - Preview

#Preview("Block Style") {
    ScrollView {
        ShortcutActionsView(url: "https://www.icloud.com/shortcuts/6256bc4845dd46d6b04b3e9fdd2ad83d")
            .padding()
    }
}
