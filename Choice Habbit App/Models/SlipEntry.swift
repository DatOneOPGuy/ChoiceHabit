import Foundation

struct SlipEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var triggerID: UUID?
    var note: String = ""
    var counteractionCompleted: Bool = false
}
