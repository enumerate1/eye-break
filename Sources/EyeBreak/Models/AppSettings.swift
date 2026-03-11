import Combine
import Foundation

class AppSettings: ObservableObject {
    private static let defaults = UserDefaults.standard

    var breakInterval: Int {
        get { Self.defaults.object(forKey: "breakInterval") as? Int ?? 1200 }
        set { objectWillChange.send(); Self.defaults.set(newValue, forKey: "breakInterval") }
    }

    var breakDuration: Int {
        get { Self.defaults.object(forKey: "breakDuration") as? Int ?? 20 }
        set { objectWillChange.send(); Self.defaults.set(newValue, forKey: "breakDuration") }
    }

    var preBreakWarning: Int {
        get { Self.defaults.object(forKey: "preBreakWarning") as? Int ?? 30 }
        set { objectWillChange.send(); Self.defaults.set(newValue, forKey: "preBreakWarning") }
    }

    var soundEnabled: Bool {
        get { Self.defaults.object(forKey: "soundEnabled") as? Bool ?? true }
        set { objectWillChange.send(); Self.defaults.set(newValue, forKey: "soundEnabled") }
    }
}
