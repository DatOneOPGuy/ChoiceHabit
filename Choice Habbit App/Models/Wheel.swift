import Foundation

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
