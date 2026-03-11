import AppKit
import Combine

class BreakOverlayNSView: NSView {
    private let titleLabel = NSTextField(labelWithString: "Look away")
    private let subtitleLabel = NSTextField(labelWithString: "Focus on something 20 feet away")
    private let timerLabel = NSTextField(labelWithString: "")
    private let skipButton = NSButton(title: "Skip", target: nil, action: nil)
    private weak var breakTimer: BreakTimer?
    private var observation: AnyCancellable?

    init(breakTimer: BreakTimer) {
        self.breakTimer = breakTimer
        super.init(frame: .zero)

        setupViews()

        observation = breakTimer.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                guard let self, let timer = self.breakTimer else { return }
                self.timerLabel.stringValue = TimerFormatter.format(timer.breakRemainingSeconds)
            }
        }

        timerLabel.stringValue = TimerFormatter.format(breakTimer.breakRemainingSeconds)

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                self?.skipButton.animator().alphaValue = 1
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func setupViews() {
        titleLabel.font = .systemFont(ofSize: 48, weight: .light)
        titleLabel.textColor = .white
        titleLabel.alignment = .center

        subtitleLabel.font = .systemFont(ofSize: 20, weight: .regular)
        subtitleLabel.textColor = .white.withAlphaComponent(0.7)
        subtitleLabel.alignment = .center

        timerLabel.font = .monospacedSystemFont(ofSize: 72, weight: .thin)
        timerLabel.textColor = .white
        timerLabel.alignment = .center

        skipButton.bezelStyle = .inline
        skipButton.isBordered = false
        skipButton.contentTintColor = .white.withAlphaComponent(0.5)
        skipButton.font = .systemFont(ofSize: 17)
        skipButton.target = self
        skipButton.action = #selector(skipTapped)
        skipButton.alphaValue = 0

        let stack = NSStackView(views: [titleLabel, subtitleLabel, timerLabel, skipButton])
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    @objc private func skipTapped() {
        breakTimer?.skipBreak()
    }

    deinit {
        observation?.cancel()
    }
}
