import SwiftUI

struct TappableSlider: View {
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        GeometryReader { geo in
            let steps = CGFloat(range.upperBound - range.lowerBound)
            let fraction = CGFloat(value - range.lowerBound) / steps
            let thumbX = fraction * geo.size.width

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray4))
                    .frame(height: 6)

                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: thumbX, height: 6)

                Circle()
                    .fill(.white)
                    .shadow(radius: 2)
                    .frame(width: 24, height: 24)
                    .offset(x: thumbX - 12)
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let fraction = max(0, min(1, drag.location.x / geo.size.width))
                        let raw = Double(range.lowerBound) + fraction * Double(steps)
                        value = max(range.lowerBound, min(range.upperBound, Int(raw.rounded())))
                    }
            )
        }
        .frame(height: 30)
    }
}
