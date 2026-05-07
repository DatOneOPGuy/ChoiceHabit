import SwiftUI

// MARK: - Stored snapshot for JSON persistence

private struct StoredData: Codable {
    var wheels: [Wheel]
    var habitPairs: [HabitPair]
    var logEntries: [LogEntry]
    var badHabits: [BadHabit]
}

@Observable
class AppData {
    var habitPairs: [HabitPair] = []
    var wheels: [Wheel] = []
    var logEntries: [LogEntry] = []
    var badHabits: [BadHabit] = []

    @ObservationIgnored private let fileURL: URL?

    init() {
        self.fileURL = Self.defaultFileURL
        loadAll()
    }

    private init(preview: Bool) {
        self.fileURL = nil
    }

    var currentStreak: Int {
        let cal = Calendar.current
        var day = cal.startOfDay(for: Date())
        var streak = 0
        while logEntries.contains(where: { cal.startOfDay(for: $0.date) == day }) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }

    func wheel(for id: UUID) -> Wheel? {
        wheels.first { $0.id == id }
    }

    func childWheel(for option: WheelOption) -> Wheel? {
        guard let childID = option.childWheelID else { return nil }
        return wheel(for: childID)
    }

    // MARK: - Load from JSON file

    private static var defaultFileURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("appdata.json")
    }

    private func loadAll() {
        guard let url = fileURL,
              FileManager.default.fileExists(atPath: url.path)
        else { return }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let stored = try decoder.decode(StoredData.self, from: data)
            wheels = stored.wheels
            habitPairs = stored.habitPairs
            logEntries = stored.logEntries
            badHabits = stored.badHabits
        } catch {
            print("Failed to load data: \(error)")
        }
    }

    // MARK: - Persist to JSON file

    func persistAll() {
        guard let url = fileURL else { return }
        let stored = StoredData(
            wheels: wheels,
            habitPairs: habitPairs,
            logEntries: logEntries,
            badHabits: badHabits
        )
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(stored)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Failed to save data: \(error)")
        }
    }

    func persistWheels() { persistAll() }
    func persistHabitPairs() { persistAll() }
    func persistLogEntries() { persistAll() }
    func persistBadHabits() { persistAll() }

    // MARK: - Clear all data (for re-onboarding)

    func clearAll() {
        wheels = []
        habitPairs = []
        badHabits = []
        logEntries = []
        persistAll()
    }

    // MARK: - Preview sample data (no persistence)

    static func sample() -> AppData {
        let data = AppData(preview: true)
        SampleData.populate(data)
        return data
    }
}
