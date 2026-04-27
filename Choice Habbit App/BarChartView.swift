import SwiftUI
import Charts

struct BarChartView: View {
    let data: [(action: String, minutes: Double)]

    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    var body: some View {
        Chart(data, id: \.action) { item in
            BarMark(
                x: .value("Action", item.action),
                y: .value("Minutes", item.minutes)
            )
            .foregroundStyle(t.accent.gradient)
            .cornerRadius(8)
            .annotation(position: .top) {
                Text(String(format: "%.1f", item.minutes))
                    .font(.caption2)
                    .foregroundStyle(t.inkMute)
            }
        }
        .frame(height: 220)
        .padding(.horizontal)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
}
