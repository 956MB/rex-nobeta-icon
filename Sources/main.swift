// Replaces the Rex Beta app icon with the same gradient icon minus the BETA pill.
// Usage: rex-nobeta-icon [dark] [--undo] [--app /path/to/Rex Beta.app]
import AppKit

var appPath = "/Applications/Rex Beta.app"
var dark = false
var undo = false
var args = CommandLine.arguments.dropFirst()
while let a = args.popFirst() {
    switch a {
    case "dark": dark = true
    case "--undo": undo = true
    case "--app": appPath = args.popFirst() ?? appPath
    case "-h", "--help":
        print("Usage: rex-nobeta-icon [dark] [--undo] [--app /path/to/Rex Beta.app]")
        exit(0)
    default:
        FileHandle.standardError.write("Unknown argument: \(a)\n".data(using: .utf8)!)
        exit(2)
    }
}

func fail(_ msg: String) -> Never {
    FileHandle.standardError.write("error: \(msg)\n".data(using: .utf8)!)
    exit(1)
}

func refreshDock() {
    _ = try? FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: appPath)
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
    p.arguments = ["Dock"]
    try? p.run()
    p.waitUntilExit()
}

guard FileManager.default.fileExists(atPath: appPath) else { fail("\(appPath) not found") }

if undo {
    guard NSWorkspace.shared.setIcon(nil, forFile: appPath, options: []) else { fail("could not remove custom icon") }
    refreshDock()
    print("Removed custom icon from \(appPath)")
    exit(0)
}

let artName = dark ? "AppIconDarkPreview" : "AppIconLightPreview"
guard let bundle = Bundle(path: appPath),
      let src = bundle.image(forResource: artName),
      let tiff = src.tiffRepresentation,
      let bm = NSBitmapImageRep(data: tiff)
else { fail("\(artName) not found in \(appPath)") }

// macOS icon grid: 824 px rounded body on a 1024 px canvas, nudged down slightly for the shadow.
guard let out = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1024, pixelsHigh: 1024, bitsPerSample: 8,
                                 samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                                 bytesPerRow: 0, bitsPerPixel: 0)
else { fail("could not create canvas") }
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: out)
NSGraphicsContext.current?.imageInterpolation = .high
let img = NSImage(size: NSSize(width: bm.pixelsWide, height: bm.pixelsHigh))
img.addRepresentation(bm)
img.draw(in: NSRect(x: 100, y: 88, width: 824, height: 824), from: .zero, operation: .sourceOver, fraction: 1)
NSGraphicsContext.restoreGraphicsState()

guard let png = out.representation(using: .png, properties: [:]), let icon = NSImage(data: png) else {
    fail("could not render icon")
}
guard NSWorkspace.shared.setIcon(icon, forFile: appPath, options: []) else {
    fail("could not set icon. Give your terminal App Management access in System Settings > Privacy & Security.")
}
refreshDock()
print("Set \(dark ? "dark" : "non-beta") icon on \(appPath). If the Dock still shows BETA while Rex runs, quit and reopen Rex.")
