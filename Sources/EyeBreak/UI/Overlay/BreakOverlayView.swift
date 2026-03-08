import SwiftUI

struct BreakOverlayView: View {
    @ObservedObject var breakTimer: BreakTimer
    @State private var showSkip = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Look away")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(.white)

            Text("Focus on something 20 feet away")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.7))

            Text(TimerFormatter.format(breakTimer.breakRemainingSeconds))
                .font(.system(size: 72, weight: .thin, design: .monospaced))
                .foregroundStyle(.white)
                .contentTransition(.numericText())

            if showSkip {
                Button("Skip") {
                    breakTimer.skipBreak()
                }
                .buttonStyle(.plain)
                .font(.title3)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.top, 20)
                .transition(.opacity)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.easeIn(duration: 0.3)) {
                    showSkip = true
                }
            }
        }
    }
}
