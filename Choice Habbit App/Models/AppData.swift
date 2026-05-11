import SwiftUI

// MARK: - Stored snapshot for JSON persistence

private struct StoredData: Codable {
    var wheels: [Wheel]
    var habitPairs: [HabitPair]
    var logEntries: [LogEntry]
    var badHabits: [BadHabit]
    var slips: [SlipEntry]
    var collectiveRedirectBase: Int

    init(wheels: [Wheel], habitPairs: [HabitPair], logEntries: [LogEntry],
         badHabits: [BadHabit], slips: [SlipEntry] = [],
         collectiveRedirectBase: Int = 23841) {
        self.wheels = wheels
        self.habitPairs = habitPairs
        self.logEntries = logEntries
        self.badHabits = badHabits
        self.slips = slips
        self.collectiveRedirectBase = collectiveRedirectBase
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        wheels = try container.decode([Wheel].self, forKey: .wheels)
        habitPairs = try container.decode([HabitPair].self, forKey: .habitPairs)
        logEntries = try container.decode([LogEntry].self, forKey: .logEntries)
        badHabits = try container.decode([BadHabit].self, forKey: .badHabits)
        slips = try container.decodeIfPresent([SlipEntry].self, forKey: .slips) ?? []
        collectiveRedirectBase = try container.decodeIfPresent(Int.self, forKey: .collectiveRedirectBase) ?? 23841
    }
}

// MARK: - Energy Level (not persisted)

enum EnergyLevel {
    case fine
    case strained
    case empty
}

@Observable
class AppData {
    var habitPairs: [HabitPair] = []
    var wheels: [Wheel] = []
    var logEntries: [LogEntry] = []
    var badHabits: [BadHabit] = []
    var slips: [SlipEntry] = []
    var collectiveRedirectBase: Int = 23841

    var currentEnergyLevel: EnergyLevel = .fine
    var energyInferredThisSession: Bool = false

    @ObservationIgnored private let fileURL: URL?

    init() {
        self.fileURL = Self.defaultFileURL
        loadAll()
        seedGreyStateWheels()
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
            slips = stored.slips
            collectiveRedirectBase = stored.collectiveRedirectBase
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
            badHabits: badHabits,
            slips: slips,
            collectiveRedirectBase: collectiveRedirectBase
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

    // MARK: - Seed Grey State Wheels

    private func seedGreyStateWheels() {
        guard wheels.filter({ $0.isGreyState }).count == 0 else { return }

        let w = 7
        let bed = Wheel(name: "Grey State — Bed", options: [
            WheelOption(label: "Remove the blanket", weight: w),
            WheelOption(label: "Sit up, feet on floor", weight: w),
            WheelOption(label: "Open one blind", weight: w),
            WheelOption(label: "One sip of water", weight: w),
            WheelOption(label: "Phone to far side of bed", weight: w),
        ], isGreyState: true)

        let couch = Wheel(name: "Grey State — Couch", options: [
            WheelOption(label: "Sit upright, feet flat", weight: w),
            WheelOption(label: "Move one cushion length", weight: w),
            WheelOption(label: "Flip screen face-down", weight: w),
            WheelOption(label: "Stand 3s — sit back down", weight: w),
            WheelOption(label: "Flip the light switch", weight: w),
        ], isGreyState: true)

        let screen = Wheel(name: "Grey State — Screen", options: [
            WheelOption(label: "Finger on power button", weight: w),
            WheelOption(label: "Close active tab", weight: w),
            WheelOption(label: "Turn chair to wall", weight: w),
            WheelOption(label: "Mute the audio", weight: w),
            WheelOption(label: "Roll chair back 30cm", weight: w),
        ], isGreyState: true)

        wheels.append(contentsOf: [bed, couch, screen])
        persistAll()
    }

    // MARK: - Clear all data (for re-onboarding)

    func clearAll() {
        wheels = []
        habitPairs = []
        badHabits = []
        logEntries = []
        slips = []
        persistAll()
    }

    // MARK: - Preview sample data (no persistence)

    static func sample() -> AppData {
        let data = AppData(preview: true)
        SampleData.populate(data)
        return data
    }
}
