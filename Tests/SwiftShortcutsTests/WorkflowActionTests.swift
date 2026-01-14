//
//  WorkflowActionTests.swift
//  SwiftShortcuts
//

import Testing
@testable import SwiftShortcuts

@Suite("WorkflowAction")
struct WorkflowActionTests {

    // MARK: - Initialization

    @Test("Initializes with all parameters")
    func initWithAllParams() {
        let action = WorkflowAction(
            identifier: "is.workflow.actions.gettext",
            controlFlowMode: .start,
            subtitle: "Test subtitle"
        )

        #expect(action.identifier == "is.workflow.actions.gettext")
        #expect(action.controlFlowMode == .start)
        #expect(action.subtitle == "Test subtitle")
    }

    @Test("Generates unique ID for each instance")
    func uniqueIDs() {
        let action1 = WorkflowAction(identifier: "test")
        let action2 = WorkflowAction(identifier: "test")

        #expect(action1.id != action2.id)
    }

    // MARK: - Control Flow Detection

    @Test("Start mode is not a control flow marker")
    func startNotMarker() {
        let action = WorkflowAction(identifier: "test", controlFlowMode: .start)
        #expect(action.isControlFlowMarker == false)
    }

    @Test("Middle mode is a control flow marker")
    func middleIsMarker() {
        let action = WorkflowAction(identifier: "test", controlFlowMode: .middle)
        #expect(action.isControlFlowMarker == true)
    }

    @Test("End mode is a control flow marker")
    func endIsMarker() {
        let action = WorkflowAction(identifier: "test", controlFlowMode: .end)
        #expect(action.isControlFlowMarker == true)
    }

    @Test("Non-control-flow action is not a marker")
    func regularActionNotMarker() {
        let action = WorkflowAction(identifier: "is.workflow.actions.gettext")
        #expect(action.isControlFlowMarker == false)
    }

    // MARK: - Display Names for Control Flow

    @Test("Conditional start shows 'If'")
    func conditionalStart() {
        let action = WorkflowAction(
            identifier: "is.workflow.actions.conditional",
            controlFlowMode: .start
        )
        #expect(action.displayName == "If")
    }

    @Test("Conditional middle shows 'Otherwise'")
    func conditionalMiddle() {
        let action = WorkflowAction(
            identifier: "is.workflow.actions.conditional",
            controlFlowMode: .middle
        )
        #expect(action.displayName == "Otherwise")
    }

    @Test("Conditional end shows 'End If'")
    func conditionalEnd() {
        let action = WorkflowAction(
            identifier: "is.workflow.actions.conditional",
            controlFlowMode: .end
        )
        #expect(action.displayName == "End If")
    }

    @Test("Menu start shows 'Menu'")
    func menuStart() {
        let action = WorkflowAction(
            identifier: "is.workflow.actions.choosefrommenu",
            controlFlowMode: .start
        )
        #expect(action.displayName == "Menu")
    }

    @Test("Menu middle shows 'Menu Item'")
    func menuMiddle() {
        let action = WorkflowAction(
            identifier: "is.workflow.actions.choosefrommenu",
            controlFlowMode: .middle
        )
        #expect(action.displayName == "Menu Item")
    }

    @Test("Menu end shows 'End Menu'")
    func menuEnd() {
        let action = WorkflowAction(
            identifier: "is.workflow.actions.choosefrommenu",
            controlFlowMode: .end
        )
        #expect(action.displayName == "End Menu")
    }

    @Test("Repeat count end shows 'End Repeat'")
    func repeatCountEnd() {
        let action = WorkflowAction(
            identifier: "is.workflow.actions.repeat.count",
            controlFlowMode: .end
        )
        #expect(action.displayName == "End Repeat")
    }

    @Test("Repeat each end shows 'End Repeat'")
    func repeatEachEnd() {
        let action = WorkflowAction(
            identifier: "is.workflow.actions.repeat.each",
            controlFlowMode: .end
        )
        #expect(action.displayName == "End Repeat")
    }

    // MARK: - System Images for Pattern Matching

    @Test("Pattern-based system images")
    func patternBasedIcons() {
        let patterns: [(String, String)] = [
            ("is.workflow.actions.deletefiles", "trash"),
            ("is.workflow.actions.transcribe", "waveform"),
            ("is.workflow.actions.record.audio", "mic"),
            ("is.workflow.actions.takevideo", "video"),
            ("is.workflow.actions.camera", "camera"),
            ("is.workflow.actions.selectphoto", "photo"),
            ("is.workflow.actions.getimages", "photo"),
            ("is.workflow.actions.calendar.add", "calendar"),
            ("is.workflow.actions.reminder.create", "checklist"),
            ("is.workflow.actions.note.create", "note.text"),
            ("is.workflow.actions.showalert", "exclamationmark.bubble"),
            ("is.workflow.actions.notification", "bell"),
            ("is.workflow.actions.conditional", "arrow.triangle.branch"),
            ("is.workflow.actions.repeat.count", "repeat"),
            ("is.workflow.actions.gettext", "text.alignleft"),
            ("is.workflow.actions.openapp", "app"),
            ("is.workflow.actions.sendmail", "envelope"),
            ("is.workflow.actions.sendmessage", "message"),
            ("is.workflow.actions.openurl", "link"),
            ("is.workflow.actions.getfile", "doc"),
            ("is.workflow.actions.getfolder", "folder"),
            ("is.workflow.actions.getclipboard", "clipboard"),
            ("is.workflow.actions.share", "square.and.arrow.up"),
            ("is.workflow.actions.download", "arrow.down.circle"),
            ("is.workflow.actions.upload", "arrow.up.circle"),
            ("is.workflow.actions.getlocation", "location"),
            ("is.workflow.actions.openmap", "map"),
            ("is.workflow.actions.weather", "cloud.sun"),
            ("is.workflow.actions.playmusic", "music.note"),
            ("is.workflow.actions.playpause", "play"),
            ("is.workflow.actions.timer.start", "timer"),
            ("is.workflow.actions.setalarm", "alarm"),
            ("is.workflow.actions.health.workout", "heart"),
            ("is.workflow.actions.homekit", "house"),
            ("is.workflow.actions.setbrightness", "sun.max"),
            ("is.workflow.actions.setvolume", "speaker.wave.2"),
            ("is.workflow.actions.flashlight", "flashlight.on.fill"),
            ("is.workflow.actions.scanqr", "qrcode"),
            ("is.workflow.actions.translate", "character.book.closed"),
            ("is.workflow.actions.calculate", "function"),
            ("is.workflow.actions.runscript", "terminal"),
            ("is.workflow.actions.ssh", "terminal"),
        ]

        for (identifier, expectedIcon) in patterns {
            let action = WorkflowAction(identifier: identifier)
            #expect(action.systemImage == expectedIcon, "\(identifier) should use \(expectedIcon)")
        }
    }

    @Test("Unknown identifier returns default gearshape")
    func unknownIdentifierDefault() {
        let action = WorkflowAction(identifier: "com.example.unknown.action")
        #expect(action.systemImage == "gearshape")
    }

    // MARK: - ControlFlowMode Raw Values

    @Test("ControlFlowMode has correct raw values")
    func controlFlowModeRawValues() {
        #expect(WorkflowAction.ControlFlowMode.start.rawValue == 0)
        #expect(WorkflowAction.ControlFlowMode.middle.rawValue == 1)
        #expect(WorkflowAction.ControlFlowMode.end.rawValue == 2)
    }
}
