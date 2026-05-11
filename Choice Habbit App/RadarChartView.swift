//
//  RadarChartView.swift
//  Choice Habbit App
//
//  Created by Joey Hansel on 26.04.26.
//

import SwiftUI

struct RadarChartView: View {
    let data: [(action: String, minutes: Double)]

    private var maxMinutes: Double {
        data.map { $0.minutes }.max() ?? 1
    }

    private var normalizedData: [(action: String, value: Double)] {
        data.prefix(8).map {
            (action: $0.action, value: $0.minutes / maxMinutes)
        }
    }

    var body: some View {
        if normalizedData.count < 3 {
            Text("Complete at least 3 different actions to see the radar chart.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = min(size.width, size.height) / 2 - 40
                let count  = normalizedData.count

                for ring in [0.25, 0.5, 0.75, 1.0] {
                    var ringPath = Path()
                    for i in 0..<count {
                        let angle = angleFor(index: i, count: count)
                        let point = pointOn(center: center, angle: angle, radius: radius * ring)
                        if i == 0 { ringPath.move(to: point) }
                        else { ringPath.addLine(to: point) }
                    }
                    ringPath.closeSubpath()
                    context.stroke(ringPath, with: .color(.primary.opacity(0.1)), lineWidth: 1)
                }

                for i in 0..<count {
                    let angle = angleFor(index: i, count: count)
                    let outer = pointOn(center: center, angle: angle, radius: radius)
                    var spoke = Path()
                    spoke.move(to: center)
                    spoke.addLine(to: outer)
                    context.stroke(spoke, with: .color(.primary.opacity(0.15)), lineWidth: 1)
                }

                var dataPath = Path()
                for (i, item) in normalizedData.enumerated() {
                    let angle = angleFor(index: i, count: count)
                    let point = pointOn(center: center, angle: angle, radius: radius * item.value)
                    if i == 0 { dataPath.move(to: point) }
                    else { dataPath.addLine(to: point) }
                }
                dataPath.closeSubpath()
                context.fill(dataPath, with: .color(Color.teal.opacity(0.3)))
                context.stroke(dataPath, with: .color(Color.teal), lineWidth: 2)

                for (i, item) in normalizedData.enumerated() {
                    let angle = angleFor(index: i, count: count)
                    let point = pointOn(center: center, angle: angle, radius: radius * item.value)
                    let dotRect = CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10)
                    context.fill(Path(ellipseIn: dotRect), with: .color(Color.teal))
                }

                for (i, item) in normalizedData.enumerated() {
                    let angle = angleFor(index: i, count: count)
                    let labelPoint = pointOn(center: center, angle: angle, radius: radius + 24)
                    context.draw(
                        Text(item.action)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary),
                        at: labelPoint
                    )
                }
            }
            .frame(height: 280)
            .padding(.horizontal)
        }
    }

    private func angleFor(index: Int, count: Int) -> Double {
        (Double(index) / Double(count)) * 2 * .pi - (.pi / 2)
    }

    private func pointOn(center: CGPoint, angle: Double, radius: Double) -> CGPoint {
        CGPoint(
            x: center.x + radius * cos(angle),
            y: center.y + radius * sin(angle)
        )
    }
}
