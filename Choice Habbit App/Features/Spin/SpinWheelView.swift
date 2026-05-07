import SwiftUI

struct SpinWheelView: View {
    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    let options: [WheelOption]

    private var totalWeight: Double {
        options.reduce(0) { $0 + Double($1.weight) }
    }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = size / 2

            ZStack {
                ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                    let start = startAngle(for: index)
                    let sweep = sliceAngle(for: option)
                    let drawStart = Angle.radians(start - .pi / 2)
                    let drawEnd = Angle.radians(start + sweep - .pi / 2)
                    let color = t.slices[index % t.slices.count]

                    Path { path in
                        path.move(to: center)
                        path.addArc(
                            center: center, radius: radius,
                            startAngle: drawStart, endAngle: drawEnd,
                            clockwise: false
                        )
                        path.closeSubpath()
                    }
                    .fill(color)

                    Path { path in
                        path.move(to: center)
                        path.addArc(
                            center: center, radius: radius,
                            startAngle: drawStart, endAngle: drawEnd,
                            clockwise: false
                        )
                        path.closeSubpath()
                    }
                    .stroke(t.surface, lineWidth: 1.5)

                    let mid = start + sweep / 2 - .pi / 2
                    let labelRadius = radius * 0.65

                    Text(option.label)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.4), radius: 1, x: 0.5, y: 0.5)
                        .rotationEffect(.radians(mid))
                        .position(
                            x: center.x + labelRadius * cos(mid),
                            y: center.y + labelRadius * sin(mid)
                        )
                }

                Circle()
                    .fill(t.surface)
                    .frame(width: 44, height: 44)
                    .position(center)

                Circle()
                    .stroke(t.line, lineWidth: 0.5)
                    .frame(width: 44, height: 44)
                    .position(center)

                Circle()
                    .fill(t.accent)
                    .frame(width: 12, height: 12)
                    .position(center)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func sliceAngle(for option: WheelOption) -> Double {
        guard totalWeight > 0 else { return 0 }
        return (Double(option.weight) / totalWeight) * 2 * .pi
    }

    private func startAngle(for index: Int) -> Double {
        options.prefix(index).reduce(0) { $0 + sliceAngle(for: $1) }
    }
}
