import SwiftUI

struct MenuBarView: View {
    @ObservedObject var breakTimer: BreakTimer

    var body: some View {
        switch breakTimer.state {
        case .idle:
            Text("EyeBreak — Not started")
            Button("Start") { breakTimer.start() }
        case .counting, .preBreak:
            Text("Next break in \(TimerFormatter.format(breakTimer.remainingSeconds))")
        case .onBreak:
            Text("On break — \(TimerFormatter.format(breakTimer.breakRemainingSeconds))")
        case .paused:
            Text("Paused — \(TimerFormatter.format(breakTimer.remainingSeconds)) remaining")
        }

        Divider()

        if breakTimer.state == .paused {
            Button("Resume") { breakTimer.resume() }
        } else if breakTimer.state == .counting || breakTimer.state == .preBreak {
            Button("Pause") { breakTimer.pause() }
            Button("Skip Next Break") { breakTimer.skipBreak() }
            Button("Postpone 5 min") { breakTimer.postpone(minutes: 5) }
        } else if breakTimer.state == .onBreak {
            Button("Skip Break") { breakTimer.skipBreak() }
        }

        Divider()

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
