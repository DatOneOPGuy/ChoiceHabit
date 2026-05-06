import SwiftUI

struct WheelSpinnerView: View {
    @Environment(AppData.self) private var appData
    let wheelID: UUID
    var trigger: String = ""
    var oldHabit: String = ""

    @State private var currentWheelID: UUID
    @State private var rotation = 0.0
    @State private var isSpinning = false
    @State private var animateRotation = false
    @State private var result: String?
    @State private var isFinalResult = false
    @State private var showingEditor = false
    @State private var navigateToTimer = false
    @State private var finalAction = ""

    init(wheelID: UUID, trigger: String = "", oldHabit: String = "") {
        self.wheelID = wheelID
        self.trigger = trigger
        self.oldHabit = oldHabit
        self._currentWheelID = State(initialValue: wheelID)
    }

    private var currentWheel: Wheel? {
        appData.wheel(for: currentWheelID)
    }

    private var currentOptions: [WheelOption] {
        currentWheel?.options ?? []
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(currentWheel?.name ?? "Spin the Wheel!")
                .font(.largeTitle.bold())
                .animation(.easeInOut, value: currentWheelID)

            ZStack(alignment: .top) {
                SpinWheelView(options: currentOptions)
                    .frame(width: 300, height: 300)
                    .rotationEffect(.radians(rotation))
                    .animation(
                        animateRotation
                            ? .timingCurve(0.12, 0.7, 0.2, 1.0, duration: 4.0)
                            : nil,
                        value: rotation
                    )

                Image(systemName: "arrowtriangle.down.fill")
                    .font(.title)
                    .foregroundStyle(.black)
                    .offset(y: -5)
            }
            .onTapGesture {
                spin()
            }

            if let result {
                Text(result)
                    .font(.title2.bold())
                    .foregroundStyle(isFinalResult ? .teal : .primary)
                    .transition(.scale.combined(with: .opacity))
            }

            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEditor = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .disabled(isSpinning)
            }
        }
        .sheet(isPresented: $showingEditor, onDismiss: {
            appData.persistWheels()
        }) {
            WeightEditorView(wheelID: currentWheelID)
        }
        .navigationDestination(isPresented: $navigateToTimer) {
            ActionTimerView(
                action: finalAction,
                trigger: trigger,
                oldHabit: oldHabit
            )
        }
    }

    private func spin() {
        guard !isSpinning else { return }
        let options = currentOptions
        guard !options.isEmpty else { return }
        isSpinning = true
        result = nil
        isFinalResult = false

        let totalWeight = options.reduce(0.0) { $0 + Double($1.weight) }
        guard totalWeight > 0 else { return }

        // Weighted random selection
        let random = Double.random(in: 0..<totalWeight)
        var cumulative = 0.0
        var selectedIndex = 0
        for (index, option) in options.enumerated() {
            cumulative += Double(option.weight)
            if random < cumulative {
                selectedIndex = index
                break
            }
        }

        // Midpoint angle of the selected slice
        var midAngle = 0.0
        for i in 0..<selectedIndex {
            midAngle += (Double(options[i].weight) / totalWeight) * 2 * .pi
        }
        midAngle += (Double(options[selectedIndex].weight) / totalWeight) * .pi

        let sliceAngle = (Double(options[selectedIndex].weight) / totalWeight) * 2 * .pi
        let jitter = Double.random(in: -sliceAngle * 0.3...sliceAngle * 0.3)
        midAngle += jitter

        let targetModulo = 2 * Double.pi - midAngle
        let currentModulo = rotation.truncatingRemainder(dividingBy: 2 * .pi)
        var delta = targetModulo - currentModulo
        if delta < 0 { delta += 2 * .pi }

        let fullRotations = Double(Int.random(in: 5...8)) * 2 * .pi

        animateRotation = true
        rotation += fullRotations + delta

        let selectedOption = options[selectedIndex]

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(4.0))

            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                result = selectedOption.label
            }

            if let childID = selectedOption.childWheelID,
               appData.wheel(for: childID) != nil {
                // Chain: show result briefly, then load child wheel
                try? await Task.sleep(for: .seconds(1.5))

                animateRotation = false
                currentWheelID = childID
                rotation = 0
                result = nil
                isSpinning = false

                // Auto-spin the child wheel after a brief pause
                try? await Task.sleep(for: .seconds(0.6))
                spin()
            } else {
                withAnimation {
                    isFinalResult = true
                }
                isSpinning = false

                // Navigate to action timer after showing final result
                try? await Task.sleep(for: .seconds(1.5))
                finalAction = selectedOption.label
                navigateToTimer = true
            }
        }
    }
}
