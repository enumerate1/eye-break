import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let breakTimer = BreakTimer()
    private var timerObservation: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            let image = NSImage(systemSymbolName: "eye", accessibilityDescription: "EyeBreak")?
                .withSymbolConfiguration(config)
            button.image = image
            button.imagePosition = .imageLeading
        }

        setupMenu()
        breakTimer.start()

        timerObservation = breakTimer.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateMenu()
            }
        }
    }

    private func setupMenu() {
        updateMenu()
    }

    private func updateMenu() {
        let menu = NSMenu()

        switch breakTimer.state {
        case .idle:
            menu.addItem(withTitle: "EyeBreak — Not started", action: nil, keyEquivalent: "")
            menu.addItem(NSMenuItem.separator())
            let startItem = NSMenuItem(title: "Start", action: #selector(startTimer), keyEquivalent: "s")
            startItem.target = self
            menu.addItem(startItem)

        case .counting, .preBreak:
            menu.addItem(withTitle: "Next break in \(TimerFormatter.format(breakTimer.remainingSeconds))", action: nil, keyEquivalent: "")
            menu.addItem(NSMenuItem.separator())
            let pauseItem = NSMenuItem(title: "Pause", action: #selector(pauseTimer), keyEquivalent: "p")
            pauseItem.target = self
            menu.addItem(pauseItem)
            let skipItem = NSMenuItem(title: "Skip Next Break", action: #selector(skipBreak), keyEquivalent: "")
            skipItem.target = self
            menu.addItem(skipItem)
            let postponeItem = NSMenuItem(title: "Postpone 5 min", action: #selector(postponeBreak), keyEquivalent: "")
            postponeItem.target = self
            menu.addItem(postponeItem)

            statusItem.button?.title = "\(TimerFormatter.format(breakTimer.remainingSeconds))"

        case .onBreak:
            menu.addItem(withTitle: "On break — \(TimerFormatter.format(breakTimer.breakRemainingSeconds))", action: nil, keyEquivalent: "")
            menu.addItem(NSMenuItem.separator())
            let skipItem = NSMenuItem(title: "Skip Break", action: #selector(skipBreak), keyEquivalent: "")
            skipItem.target = self
            menu.addItem(skipItem)

            statusItem.button?.title = "\(TimerFormatter.format(breakTimer.breakRemainingSeconds))"

        case .paused:
            menu.addItem(withTitle: "Paused — \(TimerFormatter.format(breakTimer.remainingSeconds)) remaining", action: nil, keyEquivalent: "")
            menu.addItem(NSMenuItem.separator())
            let resumeItem = NSMenuItem(title: "Resume", action: #selector(resumeTimer), keyEquivalent: "r")
            resumeItem.target = self
            menu.addItem(resumeItem)

            statusItem.button?.title = "⏸"
        }

        menu.addItem(NSMenuItem.separator())
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem.menu = menu
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
