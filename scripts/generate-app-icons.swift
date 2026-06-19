#!/usr/bin/env swift
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let pythonGenerator = root.appendingPathComponent("scripts/generate-app-icons.py")

guard FileManager.default.fileExists(atPath: pythonGenerator.path) else {
    fputs("Missing scripts/generate-app-icons.py\n", stderr)
    exit(1)
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
process.arguments = ["python3", pythonGenerator.path]
process.currentDirectoryURL = root

do {
    try process.run()
    process.waitUntilExit()
    exit(process.terminationStatus)
} catch {
    fputs("Failed to run Python AppIcon generator: \(error)\n", stderr)
    exit(1)
}
