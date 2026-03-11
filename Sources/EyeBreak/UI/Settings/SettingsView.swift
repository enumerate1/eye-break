import AppKit

class SettingsNSView: NSView {
    private let settings: AppSettings
    private let intervalLabel = NSTextField(labelWithString: "")
    private let intervalSlider = NSSlider()
    private let durationLabel = NSTextField(labelWithString: "")
    private let durationSlider = NSSlider()
    private let soundCheckbox = NSButton(checkboxWithTitle: "Sound enabled", target: nil, action: nil)

    init(settings: AppSettings) {
        self.settings = settings
        super.init(frame: NSRect(x: 0, y: 0, width: 350, height: 200))
        setupViews()
        syncFromSettings()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func setupViews() {
        intervalSlider.minValue = 10
        intervalSlider.maxValue = 3600
        intervalSlider.target = self
        intervalSlider.action = #selector(intervalChanged)

        durationSlider.minValue = 5
        durationSlider.maxValue = 120
        durationSlider.target = self
        durationSlider.action = #selector(durationChanged)

        soundCheckbox.target = self
        soundCheckbox.action = #selector(soundToggled)

        let intervalStack = NSStackView(views: [intervalLabel, intervalSlider])
        intervalStack.orientation = .vertical
        intervalStack.alignment = .leading
        intervalStack.spacing = 8

        let durationStack = NSStackView(views: [durationLabel, durationSlider])
        durationStack.orientation = .vertical
        durationStack.alignment = .leading
        durationStack.spacing = 8

        let mainStack = NSStackView(views: [intervalStack, durationStack, soundCheckbox])
        mainStack.orientation = .vertical
        mainStack.alignment = .leading
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            intervalSlider.widthAnchor.constraint(equalToConstant: 310),
            durationSlider.widthAnchor.constraint(equalToConstant: 310),
        ])
    }

    private func syncFromSettings() {
        intervalSlider.doubleValue = Double(settings.breakInterval)
        durationSlider.doubleValue = Double(settings.breakDuration)
        soundCheckbox.state = settings.soundEnabled ? .on : .off
        updateIntervalLabel()
        updateDurationLabel()
    }

    private func updateIntervalLabel() {
        let val = Int(intervalSlider.doubleValue)
        if val < 60 {
            intervalLabel.stringValue = "Break every \(val) sec"
        } else {
            intervalLabel.stringValue = "Break every \(val / 60) min"
        }
    }

    private func updateDurationLabel() {
        let val = Int(durationSlider.doubleValue)
        durationLabel.stringValue = "Break duration \(val) sec"
    }

    @objc private func intervalChanged() {
        let stepped = Int(intervalSlider.doubleValue / 10) * 10
        intervalSlider.doubleValue = Double(stepped)
        settings.breakInterval = stepped
        updateIntervalLabel()
    }

    @objc private func durationChanged() {
        let stepped = Int(durationSlider.doubleValue / 5) * 5
        durationSlider.doubleValue = Double(stepped)
        settings.breakDuration = stepped
        updateDurationLabel()
    }

    @objc private func soundToggled() {
        settings.soundEnabled = soundCheckbox.state == .on
    }
}
