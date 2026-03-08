import SwiftUI

class AppSettings: ObservableObject {
    @AppStorage("breakInterval") var breakInterval: Int = 30
    @AppStorage("breakDuration") var breakDuration: Int = 20
    @AppStorage("preBreakWarning") var preBreakWarning: Int = 30
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
}
