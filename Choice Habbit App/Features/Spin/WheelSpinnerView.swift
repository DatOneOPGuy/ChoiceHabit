import SwiftUI

struct WheelSpinnerView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    private var t: Tide { .resolve(colorScheme) }

    let wheelID: UUID
    var trigger: String = ""
    var oldHabit: String = ""
    var greyStateMode: Bool = false

    @State private var currentWheelID: UUID
    @State private var rotation = 0.0
    @State private var isSpinning = false
    @State private var animateRotation = false
    @State private var result: String?
    @State private var isFinalResult = false
    @State private var showingEditor = false
    @State private var navigateToTimer = false
    @State private var finalAction = ""

    init(wheelID: UUID, trigger: String = "", oldHabit: String = "", greyStateMode: Bool = false) {
        self.wheelID = wheelID
        self.trigger = trigger
        self.oldHabit = oldHabit
        self.greyStateMode = greyStateMode
        self._currentWheelID = State(initialValue: wheelID)
    }

    private var currentWheel: Wheel? {
        appData.wheel(for: currentWheelID)
    }

    private var currentOptions: [WheelOption] {
        currentWheel?.activeOptions ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            TopBar(leading: .back) { dismiss() }

            ScrollView {
                VStack(spacing: 0) {
                    // Title section
                    VStack(alignment: .leading, spacing: 6) {
                        TideHeadline(
                            text: "Spin for a better choice",
                            color: t.ink
                        )

                        Text("Heavier slices come up more often.")
                            .font(.system(size: 13))
                            .foregroundStyle(t.inkMute)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    Spacer(minLength: 18)

                    // Wheel
                    wheelSection

                    if result == nil {
                        Text("Tap the wheel to spin")
                            .font(.system(size: 13))
                            .foregroundStyle(t.inkMute)
                            .padding(.top, 8)
                    }

                    if let result {
                        Text(result)
                            .font(.title2.bold())
                            .foregroundStyle(t.accent)
                            .transition(.scale.combined(with: .opacity))
                            .padding(.top, 12)
                    }

                    Spacer(minLength: 16)

                    if greyStateMode {
                        if isFinalResult {
                            greyStateDoneButton
                        }
                    } else {
                        footerCard
                    }
                }
            }
        }
        .background(t.bg.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
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

    // MARK: - Wheel

    private var wheelSection: some View {
        ZStack(alignment: .top) {
            Circle()
                .fill(t.surfaceAlt.opacity(0.5))
                .frame(width: 320, height: 320)

            SpinWheelView(options: currentOptions)
                .frame(width: 300, height: 300)
                .rotationEffect(.radians(rotation))
                .animation(
                    animateRotation
                        ? .timingCurve(0.12, 0.7, 0.2, 1.0, duration: 4.0)
                        : nil,
                    value: rotation
                )
                .shadow(
                    color: colorScheme == .dark
                        ? Color(red: 0, green: 0, blue: 0, opacity: 0.4)
                        : Color(red: 15/255, green: 42/255, blue: 46/255, opacity: 0.12),
                    radius: 12, x: 0, y: 4
                )

            // Sienna pointer
            Triangle()
                .fill(t.warm)
                .stroke(t.bg, lineWidth: 1.5)
                .frame(width: 14, height: 18)
                .offset(y: -4)
        }
        .frame(width: 320, height: 330)
        .onTapGesture {
            spin()
        }
    }

    // MARK: - Footer Card

    private var footerCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(t.accent)
                    .frame(width: 32, height: 32)
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Eyebrow(
                    text: "\(currentOptions.count) PATHS \u{00B7} WEIGHTED BY WHAT WORKS",
                    color: t.inkMute
                )
                Text("Let the wheel decide for you.")
                    .font(.system(size: 14))
                    .foregroundStyle(t.inkSoft)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(t.surfaceAlt)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(t.line, lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    // MARK: - Grey State Done Button

    private var greyStateDoneButton: some View {
        Button("Done") { dismiss() }
            .font(.title3.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(t.accent)
            .foregroundStyle(t.accentInk)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
    }

    // MARK: - Spin Logic

    private func spin() {
        guard !isSpinning else { return }
        let options = currentOptions
        guard !options.isEmpty else { return }
        isSpinning = true
        result = nil
        isFinalResult = false

        let totalWeight = options.reduce(0.0) { $0 + Double($1.weight) }
        guard totalWeight > 0 else { return }

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

            if let wi = appData.wheels.firstIndex(where: { $0.id == currentWheelID }),
               let oi = appData.wheels[wi].options.firstIndex(where: { $0.id == selectedOption.id }) {
                appData.wheels[wi].options[oi].lastUsed = Date()
                appData.persistWheels()
            }

            if let childID = selectedOption.childWheelID,
               appData.wheel(for: childID) != nil {
                try? await Task.sleep(for: .seconds(1.5))

                animateRotation = false
                currentWheelID = childID
                rotation = 0
                result = nil
                isSpinning = false

                try? await Task.sleep(for: .seconds(0.6))
                spin()
            } else {
                withAnimation {
                    isFinalResult = true
                }
                isSpinning = false

                if greyStateMode {
                    // Result label is already shown — that is the entire output
                } else {
                    try? await Task.sleep(for: .seconds(1.5))
                    finalAction = selectedOption.label
                    navigateToTimer = true
                }
            }
        }
    }
}

// MARK: - Triangle Shape (pointer)

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.closeSubpath()
        }
    }
}
