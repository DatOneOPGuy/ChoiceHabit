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
            let hubRadius = size * 0.12

            ZStack {
                // Slices
                ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                    let start = startAngle(for: index)
                    let sweep = sliceAngle(for: option)
                    let drawStart = Angle.radians(start - .pi / 2)
                    let drawEnd = Angle.radians(start + sweep - .pi / 2)
                    let color = t.wheelSlices[index % t.wheelSlices.count]

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
                    .stroke(t.bg, lineWidth: 1.5)

                    // Radial label
                    let mid = start + sweep / 2 - .pi / 2
                    let labelRadius = radius * 0.62
                    let midDeg = mid * 180 / .pi
                    let onLeft = cos(mid) < 0
                    let textRot = onLeft ? midDeg + 180 : midDeg

                    Text(option.label)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(hex: 0xFBF8F2).opacity(0.95))
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0.5, y: 0.5)
                        .rotationEffect(.degrees(textRot))
                        .position(
                            x: center.x + labelRadius * cos(mid),
                            y: center.y + labelRadius * sin(mid)
                        )
                }

                // Outer ring
                Circle()
                    .stroke(
                        colorScheme == .dark
                            ? Color.white.opacity(0.08)
                            : Color.black.opacity(0.06),
                        lineWidth: 1
                    )
                    .frame(width: size, height: size)
                    .position(center)

                // Center hub
                Circle()
                    .fill(t.bg)
                    .frame(width: hubRadius * 2, height: hubRadius * 2)
                    .position(center)

                Circle()
                    .stroke(t.line, lineWidth: 1)
                    .frame(width: hubRadius * 2, height: hubRadius * 2)
                    .position(center)

                // "SPIN" text
                Text("SPIN")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(2.0)
                    .foregroundStyle(t.inkMute)
                    .position(x: center.x, y: center.y - 4)

                // Refresh icon
                Text("↻")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(t.accent)
                    .position(x: center.x, y: center.y + 11)
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
