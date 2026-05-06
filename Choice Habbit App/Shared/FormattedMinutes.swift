import Foundation

func formattedMinutes(_ minutes: Double) -> String {
    if minutes < 1 {
        return "\(Int(minutes * 60))s"
    } else if minutes < 60 {
        return String(format: "%.1f mins", minutes)
    } else {
        let hours = Int(minutes / 60)
        let mins = Int(minutes.truncatingRemainder(dividingBy: 60))
        return "\(hours)h \(mins)m"
    }
}
