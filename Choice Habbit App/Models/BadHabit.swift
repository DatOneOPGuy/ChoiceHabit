import Foundation

enum HabitFunction: String, Codable, CaseIterable {
    case boredom       = "Bored"
    case anxiety       = "Anxious / Stressed"
    case loneliness    = "Lonely / Disconnected"
    case numbness      = "Numb / Empty"
    case restlessness  = "Restless / Agitated"
}

struct BadHabit: Identifiable, Codable {
    var id = UUID()
    var name: String
    var primaryFunction: HabitFunction = .boredom
}
