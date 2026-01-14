//
//  SSTools.swift
//  SwiftShortcuts
//
//  CLI tools for SwiftShortcuts development.
//

import ArgumentParser

@main
struct SSTools: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "sstools",
        abstract: "Development tools for SwiftShortcuts",
        subcommands: [
            DumpGlyphs.self,
            FetchShortcut.self,
        ]
    )
}
