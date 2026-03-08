import AppKit
import SwiftUI

class OverlayController {
    static let shared = OverlayController()
    private var windows: [NSWindow] = []
    private var keyMonitor: Any?

    func showOverlay(breakTimer: BreakTimer) {
        dismissOverlay()

        for screen in NSScreen.screens {
            let hostingView = NSHostingView(
                rootView: BreakOverlayView(breakTimer: breakTimer)
            )
            let window = BreakOverlayWindow.create(for: screen, contentView: hostingView)
            window.alphaValue = 0
            window.makeKeyAndOrderFront(nil)

            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                window.animator().alphaValue = 1
            }

            windows.append(window)
        }

        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // Esc key
                breakTimer.skipBreak()
                return nil
            }
            return event
        }
    }

    func dismissOverlay() {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }

        let windowsToClose = windows
        windows.removeAll()

        for window in windowsToClose {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.2
                window.animator().alphaValue = 0
            }, completionHandler: {
                window.orderOut(nil)
            })
        }
    }
}
