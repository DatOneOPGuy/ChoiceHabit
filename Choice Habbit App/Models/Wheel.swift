import Foundation

struct WheelOption: Identifiable, Codable {
    var id = UUID()
    var label: String
    var weight: Int           // 1–10
    var childWheelID: UUID?   // if set, spinning this leads to another wheel
    var skipCount: Int = 0
    var lastUsed: Date? = nil
}

struct Wheel: Identifiable, Codable {
    var id = UUID()
    var name: String
    var options: [WheelOption]
    var isGreyState: Bool = false

    var activeOptions: [WheelOption] {
        options.filter { $0.skipCount < 3 }
    }
}
