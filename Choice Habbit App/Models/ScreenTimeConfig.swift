import Foundation

// MARK: - App Group Constants

enum ScreenTimeConstants {
    static let appGroupID = "group.JH.Choice-Habbit-App"
    static let configKey = "screenTimeConfig"
}

// MARK: - App Limit Rule

struct AppLimitRule: Identifiable, Codable {
    var id = UUID()
    var name: String
    var activitySelectionData: Data?
    var timeLimitMinutes: Int
    var activeDays: Set<Int> // 1=Sunday...7=Saturday (Calendar.weekday)
    var activeStartHour: Int? // nil = all day
    var activeStartMinute: Int?
    var activeEndHour: Int?
    var activeEndMinute: Int?
    var isEnabled: Bool = true

    var scheduleSummary: String {
        let dayNames = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let days = activeDays.sorted().compactMap { dayNames[safe: $0] }
        let dayStr = days.count == 7 ? "Every day"
            : days.count == 5 && !activeDays.contains(1) && !activeDays.contains(7)
                ? "Weekdays"
            : days.count == 2 && activeDays.contains(1) && activeDays.contains(7)
                ? "Weekends"
            : days.joined(separator: ", ")

        if let sh = activeStartHour, let eh = activeEndHour {
            let sm = activeStartMinute ?? 0
            let em = activeEndMinute ?? 0
            return "\(dayStr), \(formatTime(sh, sm))–\(formatTime(eh, em))"
        }
        return dayStr
    }

    var limitLabel: String {
        if timeLimitMinutes < 60 {
            return "\(timeLimitMinutes) min"
        }
        let h = timeLimitMinutes / 60
        let m = timeLimitMinutes % 60
        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
    }

    private func formatTime(_ hour: Int, _ minute: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let ampm = hour < 12 ? "AM" : "PM"
        return minute > 0
            ? "\(h):\(String(format: "%02d", minute)) \(ampm)"
            : "\(h) \(ampm)"
    }
}

// MARK: - Top-Level Config

struct ScreenTimeConfig: Codable {
    var isMonitoringEnabled: Bool = false
    var isAuthorized: Bool = false
    var rules: [AppLimitRule] = []
}

// MARK: - App Group UserDefaults

extension UserDefaults {
    static var appGroup: UserDefaults {
        UserDefaults(suiteName: ScreenTimeConstants.appGroupID)
            ?? .standard
    }
}

extension ScreenTimeConfig {
    static func load() -> ScreenTimeConfig {
        guard let data = UserDefaults.appGroup.data(
            forKey: ScreenTimeConstants.configKey
        ) else { return ScreenTimeConfig() }

        return (try? JSONDecoder().decode(
            ScreenTimeConfig.self, from: data
        )) ?? ScreenTimeConfig()
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.appGroup.set(data, forKey: ScreenTimeConstants.configKey)
    }
}

// MARK: - Safe Array Subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
