import Combine
import AppKit

class BreakTimer: ObservableObject {
    @Published var state: BreakState = .idle
    @Published var remainingSeconds: Int = 1200
    @Published var breakRemainingSeconds: Int = 20

    var menuBarTitle: String {
        switch state {
        case .idle:
            return "EyeBreak"
        case .counting, .preBreak:
            return TimerFormatter.format(remainingSeconds)
        case .onBreak:
            return "Break \(TimerFormatter.format(breakRemainingSeconds))"
        case .paused:
            return "Paused"
        }
    }

    private var timer: AnyCancellable?
    private let settings = AppSettings()
    private var settingsObservation: AnyCancellable?

    init() {
        settingsObservation = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.onSettingsChanged()
            }
    }

    deinit {
        timer?.cancel()
        settingsObservation?.cancel()
    }

    func start() {
        remainingSeconds = settings.breakInterval
        breakRemainingSeconds = settings.breakDuration
        state = .counting
        startTimer()
    }

    private func onSettingsChanged() {
        guard state == .counting || state == .preBreak else { return }
        remainingSeconds = settings.breakInterval
        state = .counting
    }

    func pause() {
        guard state == .counting || state == .preBreak else { return }
        state = .paused
        stopTimer()
    }

    func resume() {
        guard state == .paused else { return }
        state = .counting
        startTimer()
    }

    func skipBreak() {
        OverlayController.shared.dismissOverlay()
        remainingSeconds = settings.breakInterval
        breakRemainingSeconds = settings.breakDuration
        state = .counting
        startTimer()
    }

    func postpone(minutes: Int) {
        guard state == .counting || state == .preBreak else { return }
        remainingSeconds += minutes * 60
        if state == .preBreak {
            state = .counting
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.publish(every: 1, tolerance: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    private func tick() {
        switch state {
        case .counting, .preBreak:
            remainingSeconds -= 1

            if remainingSeconds <= settings.preBreakWarning && state == .counting {
                state = .preBreak
            }

            if remainingSeconds <= 0 {
                state = .onBreak
                breakRemainingSeconds = settings.breakDuration
                if settings.soundEnabled {
                    NSSound(named: "Glass")?.play()
                }
                OverlayController.shared.showOverlay(breakTimer: self)
            }

        case .onBreak:
            breakRemainingSeconds -= 1

            if breakRemainingSeconds <= 0 {
                if settings.soundEnabled {
                    NSSound(named: "Ping")?.play()
                }
                OverlayController.shared.dismissOverlay()
                state = .counting
                remainingSeconds = settings.breakInterval
            }

        case .idle, .paused:
            break
        }
    }
}
