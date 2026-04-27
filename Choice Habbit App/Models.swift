import SwiftUI

struct WheelOption: Identifiable, Codable {
    var id = UUID()
    var label: String
    var weight: Int           // 1–10
    var childWheelID: UUID?   // if set, spinning this leads to another wheel
}

struct Wheel: Identifiable, Codable {
    var id = UUID()
    var name: String
    var options: [WheelOption]
}

struct HabitPair: Identifiable, Codable {
    var id = UUID()
    var trigger: String       // e.g. "Boredom"
    var oldHabit: String      // e.g. "Scrolling phone"
    var parentWheelID: UUID   // points to the wheel to spin first
}

struct BadHabit: Identifiable, Codable {
    var id = UUID()
    var name: String
}

struct LogEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var trigger: String
    var oldHabit: String
    var newAction: String
    var minutesSpent: Double
}

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
        if wheels.isEmpty && habitPairs.isEmpty {
            seedSampleData()
        }
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

    // MARK: - Seed sample data on first launch

    private func seedSampleData() {
        let exerciseWheel = Wheel(name: "Exercise Options", options: [
            WheelOption(label: "Push-ups", weight: 5),
            WheelOption(label: "Walk", weight: 8),
            WheelOption(label: "Stretch", weight: 3),
        ])
        let mindWheel = Wheel(name: "Mind Options", options: [
            WheelOption(label: "Read", weight: 7),
            WheelOption(label: "Journal", weight: 4),
            WheelOption(label: "Meditate", weight: 6),
        ])
        let boredomWheel = Wheel(name: "Boredom", options: [
            WheelOption(label: "Physical", weight: 7, childWheelID: exerciseWheel.id),
            WheelOption(label: "Mental", weight: 6, childWheelID: mindWheel.id),
            WheelOption(label: "Creative", weight: 4),
        ])

        let stressWheel = Wheel(name: "Stress Relief", options: [
            WheelOption(label: "Deep breathing", weight: 7),
            WheelOption(label: "Walk outside", weight: 8),
            WheelOption(label: "Listen to music", weight: 5),
            WheelOption(label: "Stretch", weight: 4),
            WheelOption(label: "Call a friend", weight: 3),
        ])

        let procrastinationWheel = Wheel(name: "Quick Starts", options: [
            WheelOption(label: "2-min tidy up", weight: 6),
            WheelOption(label: "Write one sentence", weight: 7),
            WheelOption(label: "Set a 5-min timer", weight: 8),
            WheelOption(label: "Make a to-do list", weight: 5),
        ])

        let anxietyWheel = Wheel(name: "Grounding", options: [
            WheelOption(label: "5-4-3-2-1 senses", weight: 8),
            WheelOption(label: "Cold water on face", weight: 5),
            WheelOption(label: "Box breathing", weight: 7),
            WheelOption(label: "Name 3 things you see", weight: 6),
        ])

        let angerWheel = Wheel(name: "Cool Down", options: [
            WheelOption(label: "Count to 10", weight: 6),
            WheelOption(label: "Squeeze ice cube", weight: 5),
            WheelOption(label: "Go for a run", weight: 7),
            WheelOption(label: "Write it out", weight: 4),
            WheelOption(label: "Progressive muscle relax", weight: 5),
        ])

        let arousalWheel = Wheel(name: "Redirect Energy", options: [
            WheelOption(label: "Cold shower", weight: 6),
            WheelOption(label: "Intense workout", weight: 8),
            WheelOption(label: "Go for a walk", weight: 7),
            WheelOption(label: "Clean the house", weight: 5),
            WheelOption(label: "Call someone", weight: 4),
        ])

        wheels = [
            exerciseWheel, mindWheel,
            boredomWheel, stressWheel, procrastinationWheel,
            anxietyWheel, angerWheel, arousalWheel,
        ]

        habitPairs = [
            HabitPair(trigger: "Boredom", oldHabit: "Scrolling phone", parentWheelID: boredomWheel.id),
            HabitPair(trigger: "Stress", oldHabit: "Stress eating", parentWheelID: stressWheel.id),
            HabitPair(trigger: "Procrastination", oldHabit: "Putting things off", parentWheelID: procrastinationWheel.id),
            HabitPair(trigger: "Anxiety", oldHabit: "Overthinking", parentWheelID: anxietyWheel.id),
            HabitPair(trigger: "Anger", oldHabit: "Lashing out", parentWheelID: angerWheel.id),
            HabitPair(trigger: "Arousal", oldHabit: "Impulsive behavior", parentWheelID: arousalWheel.id),
        ]

        badHabits = [
            BadHabit(name: "Scrolling phone"),
            BadHabit(name: "Smoking"),
            BadHabit(name: "Playing video games"),
        ]

        persistAll()
    }

    // MARK: - Preview sample data (no persistence)

    static func sample() -> AppData {
        let data = AppData(preview: true)

        let exerciseWheel = Wheel(name: "Exercise Options", options: [
            WheelOption(label: "Push-ups", weight: 5),
            WheelOption(label: "Walk", weight: 8),
            WheelOption(label: "Stretch", weight: 3),
        ])
        let mindWheel = Wheel(name: "Mind Options", options: [
            WheelOption(label: "Read", weight: 7),
            WheelOption(label: "Journal", weight: 4),
            WheelOption(label: "Meditate", weight: 6),
        ])
        let boredomWheel = Wheel(name: "Boredom", options: [
            WheelOption(label: "Physical", weight: 7, childWheelID: exerciseWheel.id),
            WheelOption(label: "Mental", weight: 6, childWheelID: mindWheel.id),
            WheelOption(label: "Creative", weight: 4),
        ])

        let stressWheel = Wheel(name: "Stress Relief", options: [
            WheelOption(label: "Deep breathing", weight: 7),
            WheelOption(label: "Walk outside", weight: 8),
            WheelOption(label: "Listen to music", weight: 5),
            WheelOption(label: "Stretch", weight: 4),
            WheelOption(label: "Call a friend", weight: 3),
        ])

        let procrastinationWheel = Wheel(name: "Quick Starts", options: [
            WheelOption(label: "2-min tidy up", weight: 6),
            WheelOption(label: "Write one sentence", weight: 7),
            WheelOption(label: "Set a 5-min timer", weight: 8),
            WheelOption(label: "Make a to-do list", weight: 5),
        ])

        let anxietyWheel = Wheel(name: "Grounding", options: [
            WheelOption(label: "5-4-3-2-1 senses", weight: 8),
            WheelOption(label: "Cold water on face", weight: 5),
            WheelOption(label: "Box breathing", weight: 7),
            WheelOption(label: "Name 3 things you see", weight: 6),
        ])

        let angerWheel = Wheel(name: "Cool Down", options: [
            WheelOption(label: "Count to 10", weight: 6),
            WheelOption(label: "Squeeze ice cube", weight: 5),
            WheelOption(label: "Go for a run", weight: 7),
            WheelOption(label: "Write it out", weight: 4),
            WheelOption(label: "Progressive muscle relax", weight: 5),
        ])

        let arousalWheel = Wheel(name: "Redirect Energy", options: [
            WheelOption(label: "Cold shower", weight: 6),
            WheelOption(label: "Intense workout", weight: 8),
            WheelOption(label: "Go for a walk", weight: 7),
            WheelOption(label: "Clean the house", weight: 5),
            WheelOption(label: "Call someone", weight: 4),
        ])

        data.wheels = [
            exerciseWheel, mindWheel,
            boredomWheel, stressWheel, procrastinationWheel,
            anxietyWheel, angerWheel, arousalWheel,
        ]

        data.habitPairs = [
            HabitPair(trigger: "Boredom", oldHabit: "Scrolling phone", parentWheelID: boredomWheel.id),
            HabitPair(trigger: "Stress", oldHabit: "Stress eating", parentWheelID: stressWheel.id),
            HabitPair(trigger: "Procrastination", oldHabit: "Putting things off", parentWheelID: procrastinationWheel.id),
            HabitPair(trigger: "Anxiety", oldHabit: "Overthinking", parentWheelID: anxietyWheel.id),
            HabitPair(trigger: "Anger", oldHabit: "Lashing out", parentWheelID: angerWheel.id),
            HabitPair(trigger: "Arousal", oldHabit: "Impulsive behavior", parentWheelID: arousalWheel.id),
        ]

        data.badHabits = [
            BadHabit(name: "Scrolling phone"),
            BadHabit(name: "Smoking"),
            BadHabit(name: "Playing video games"),
        ]

        return data
    }
}
