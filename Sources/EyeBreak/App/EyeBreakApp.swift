import AppKit

private let appDelegate = AppDelegate()

@main
enum EyeBreakLauncher {
    static func main() {
        let app = NSApplication.shared
        app.delegate = appDelegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}
