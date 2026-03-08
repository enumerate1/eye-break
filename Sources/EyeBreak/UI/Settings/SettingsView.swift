import SwiftUI

struct SettingsView: View {
    @AppStorage("breakInterval") private var breakInterval: Int = 1200
    @AppStorage("breakDuration") private var breakDuration: Int = 20
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true

    private var intervalLabel: String {
        if breakInterval < 60 {
            return "\(breakInterval) sec"
        } else {
            return "\(breakInterval / 60) min"
        }
    }

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Break every **\(intervalLabel)**")
                    Slider(value: Binding(
                        get: { Double(breakInterval) },
                        set: { breakInterval = Int($0) }
                    ), in: 10...3600, step: 10)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Break duration **\(breakDuration) sec**")
                    Slider(value: Binding(
                        get: { Double(breakDuration) },
                        set: { breakDuration = Int($0) }
                    ), in: 5...120, step: 5)
                }

            }

            Section {
                Toggle("Sound enabled", isOn: $soundEnabled)
            }
        }
        .formStyle(.grouped)
        .frame(width: 350, height: 220)
        .fixedSize()
    }
}
