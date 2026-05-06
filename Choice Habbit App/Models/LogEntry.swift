import Foundation

struct LogEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var trigger: String
    var oldHabit: String
    var newAction: String
    var minutesSpent: Double
}
