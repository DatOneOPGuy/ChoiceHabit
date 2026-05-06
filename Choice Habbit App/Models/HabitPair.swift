import Foundation

struct HabitPair: Identifiable, Codable {
    var id = UUID()
    var trigger: String       // e.g. "Boredom"
    var oldHabit: String      // e.g. "Scrolling phone"
    var parentWheelID: UUID   // points to the wheel to spin first
}
