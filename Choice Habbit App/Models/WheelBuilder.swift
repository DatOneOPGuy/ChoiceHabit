import Foundation

// MARK: - Catalog Entry

struct CatalogEntry {
    let label: String
    let weight: Int
    let triggers: Set<String>
    let functions: [HabitFunction]

    init(label: String, weight: Int, triggers: [String], functions: [HabitFunction] = []) {
        self.label = label
        self.weight = weight
        self.triggers = Set(triggers)
        self.functions = functions
    }
}

// MARK: - WheelBuilder

enum WheelBuilder {

    static func populate(_ appData: AppData, profile: OnboardingProfile) {
        let pool = buildPool(
            worldview: profile.worldview,
            faithDetail: profile.faithDetail
        )

        let userFunctions = Set(profile.habitFunctions.values)

        var wheels: [Wheel] = []
        var habitPairs: [HabitPair] = []

        for trigger in profile.selectedTriggers.sorted() {
            var matched = pool.filter { $0.triggers.contains(trigger) }
            if matched.count < 4 {
                let extras = pool
                    .filter { !$0.triggers.contains(trigger) }
                    .sorted { $0.weight > $1.weight }
                let needed = 4 - matched.count
                matched.append(contentsOf: extras.prefix(needed))
            }

            let options = matched.map { entry -> WheelOption in
                var adjustedWeight = entry.weight
                if !entry.functions.isEmpty && !userFunctions.isEmpty {
                    if !Set(entry.functions).isDisjoint(with: userFunctions) {
                        adjustedWeight = Int(Double(entry.weight) * 1.5)
                    }
                }
                return WheelOption(label: entry.label, weight: min(adjustedWeight, 10))
            }
            let wheel = Wheel(
                name: wheelName(for: trigger),
                options: options
            )
            wheels.append(wheel)

            let oldHabit = bestHabit(
                for: trigger,
                from: profile.selectedBadHabits
            )
            habitPairs.append(HabitPair(
                trigger: trigger,
                oldHabit: oldHabit,
                parentWheelID: wheel.id
            ))
        }

        appData.wheels = wheels
        appData.habitPairs = habitPairs
        appData.badHabits = profile.selectedBadHabits.map {
            BadHabit(name: $0, primaryFunction: profile.habitFunctions[$0] ?? .boredom)
        }
        appData.persistAll()
    }

    // MARK: - Pool Builder

    private static func buildPool(
        worldview: Worldview?,
        faithDetail: FaithDetail?
    ) -> [CatalogEntry] {
        var pool = secularBase
        switch worldview {
        case .spiritual:
            pool += spiritualAdditions
        case .religious:
            pool += faithAdditions(for: faithDetail)
        case .secular, .preferNotToSay, .none:
            break
        }
        return pool
    }

    private static func faithAdditions(
        for faith: FaithDetail?
    ) -> [CatalogEntry] {
        switch faith {
        case .christian: return christianAdditions
        case .muslim: return muslimAdditions
        case .jewish: return jewishAdditions
        case .hindu: return hinduAdditions
        case .buddhist: return buddhistAdditions
        case .sikh: return sikhAdditions
        case .other, .none: return spiritualAdditions
        }
    }

    // MARK: - Trigger → Wheel Name

    private static func wheelName(for trigger: String) -> String {
        switch trigger {
        case "Boredom": return "Boredom Busters"
        case "Stress": return "Stress Relief"
        case "Anxiety": return "Calm & Ground"
        case "Anger": return "Cool Down"
        case "Loneliness": return "Connection"
        case "Arousal": return "Redirect Energy"
        case "Procrastination": return "Quick Starts"
        case "Sadness": return "Lift Your Spirits"
        default: return "\(trigger) Relief"
        }
    }

    // MARK: - Bad Habit → Trigger Mapping

    private static let habitTriggerMap: [String: Set<String>] = [
        "Scrolling phone": ["Boredom", "Procrastination"],
        "Smoking": ["Stress", "Anxiety", "Boredom"],
        "Overeating": ["Stress", "Sadness", "Boredom"],
        "Procrastinating": ["Procrastination", "Boredom"],
        "Anger issues": ["Anger", "Stress"],
        "Porn / lust": ["Arousal", "Boredom", "Loneliness"],
        "Substance use": ["Stress", "Sadness", "Anxiety"],
        "Nail biting": ["Anxiety", "Stress", "Boredom"],
        "Gambling": ["Boredom", "Stress", "Arousal"],
    ]

    private static func bestHabit(
        for trigger: String,
        from habits: Set<String>
    ) -> String {
        for habit in habits {
            if habitTriggerMap[habit]?.contains(trigger) == true {
                return habit
            }
        }
        return habits.first ?? "Bad habit"
    }
}
