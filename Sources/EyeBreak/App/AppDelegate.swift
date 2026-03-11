import AppKit
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let breakTimer = BreakTimer()
    private var timerObservation: AnyCancellable?

    private var statusMenuItem: NSMenuItem!
    private var startItem: NSMenuItem!
    private var pauseItem: NSMenuItem!
    private var skipItem: NSMenuItem!
    private var postponeItem: NSMenuItem!
    private var resumeItem: NSMenuItem!
    private var lastState: BreakState?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            let image = NSImage(systemSymbolName: "eye", accessibilityDescription: "EyeBreak")?
                .withSymbolConfiguration(config)
            button.image = image
            button.imagePosition = .imageLeading
        }

        buildMenu()
        breakTimer.start()

        timerObservation = breakTimer.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateMenu()
            }
        }
    }

    private func buildMenu() {
        let menu = NSMenu()

        statusMenuItem = menu.addItem(withTitle: "", action: nil, keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())

        startItem = NSMenuItem(title: "Start", action: #selector(startTimer), keyEquivalent: "s")
        startItem.target = self
        menu.addItem(startItem)

        pauseItem = NSMenuItem(title: "Pause", action: #selector(pauseTimer), keyEquivalent: "p")
        pauseItem.target = self
        menu.addItem(pauseItem)

        resumeItem = NSMenuItem(title: "Resume", action: #selector(resumeTimer), keyEquivalent: "r")
        resumeItem.target = self
        menu.addItem(resumeItem)

        skipItem = NSMenuItem(title: "Skip Next Break", action: #selector(skipBreak), keyEquivalent: "")
        skipItem.target = self
        menu.addItem(skipItem)

        postponeItem = NSMenuItem(title: "Postpone 5 min", action: #selector(postponeBreak), keyEquivalent: "")
        postponeItem.target = self
        menu.addItem(postponeItem)

        menu.addItem(NSMenuItem.separator())
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem.menu = menu
        updateMenu()
    }

    private func updateMenu() {
        let state = breakTimer.state

        switch state {
        case .idle:
            statusMenuItem.title = "EyeBreak — Not started"
            statusItem.button?.title = ""
        case .counting, .preBreak:
            statusMenuItem.title = "Next break in \(TimerFormatter.format(breakTimer.remainingSeconds))"
            statusItem.button?.title = TimerFormatter.format(breakTimer.remainingSeconds)
        case .onBreak:
            statusMenuItem.title = "On break — \(TimerFormatter.format(breakTimer.breakRemainingSeconds))"
            statusItem.button?.title = TimerFormatter.format(breakTimer.breakRemainingSeconds)
        case .paused:
            statusMenuItem.title = "Paused — \(TimerFormatter.format(breakTimer.remainingSeconds)) remaining"
            statusItem.button?.title = "⏸"
        }

        guard state != lastState else { return }
        lastState = state

        startItem.isHidden = state != .idle
        pauseItem.isHidden = !(state == .counting || state == .preBreak)
        skipItem.isHidden = !(state == .counting || state == .preBreak || state == .onBreak)
        postponeItem.isHidden = !(state == .counting || state == .preBreak)
        resumeItem.isHidden = state != .paused

        if state == .onBreak {
            skipItem.title = "Skip Break"
        } else {
            skipItem.title = "Skip Next Break"
        }
    }

    @objc private func startTimer() { breakTimer.start() }
    @objc private func pauseTimer() { breakTimer.pause() }
    @objc private func resumeTimer() { breakTimer.resume() }
    @objc private func skipBreak() { breakTimer.skipBreak() }
    @objc private func postponeBreak() { breakTimer.postpone(minutes: 5) }
    @objc private func openSettings() { SettingsWindowController.shared.showSettings() }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            SettingsWindowController.shared.showSettings()
        }
        return true
    }
}
