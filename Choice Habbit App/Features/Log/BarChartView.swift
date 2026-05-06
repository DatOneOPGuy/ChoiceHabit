//
//  BarChartView.swift
//  Choice Habbit App
//
//  Created by Joey Hansel on 26.04.26.
//

import SwiftUI
import Charts

struct BarChartView: View {
    let data: [(action: String, minutes: Double)]

    var body: some View {
        Chart(data, id: \.action) { item in
            BarMark(
                x: .value("Action", item.action),
                y: .value("Minutes", item.minutes)
            )
            .foregroundStyle(Color.teal.gradient)
            .cornerRadius(8)
            .annotation(position: .top) {
                Text(String(format: "%.1f", item.minutes))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 220)
        .padding(.horizontal)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
}
