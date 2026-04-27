import SwiftUI

enum BreathPhase: CaseIterable {
    case breatheIn, hold, breatheOut

    var label: String {
        switch self {
        case .breatheIn:  return "Breathe in"
        case .hold:       return "Hold"
        case .breatheOut: return "Breathe out"
        }
    }

    var duration: Int { 4 }

    var ringScale: CGFloat {
        switch self {
        case .breatheIn:  return 1.0
        case .hold:       return 1.0
        case .breatheOut: return 0.85
        }
    }
}

struct SpaceView: View {
    let trigger: String
    var wheelID: UUID? = nil
    let onComplete: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    @State private var phaseIndex = 0
    @State private var ringScale: CGFloat = 0.85
    @State private var ringOpacity: Double = 0.7
    @State private var fadeIn: Double = 0
    @State private var secondsLeft = 4
    @State private var timer: Timer?
    @State private var navigateToWheel = false

    private var currentPhase: BreathPhase {
        BreathPhase.allCases[phaseIndex]
    }

    var body: some View {
        ZStack {
            t.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button { finish() } label: {
                        Text("Skip")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(2.0)
                            .textCase(.uppercase)
                            .foregroundStyle(t.inkMute)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // Header
                VStack(spacing: 12) {
                    Eyebrow(text: "BEFORE YOU CHOOSE", color: t.inkMute)

                    (Text("One breath.\n")
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .tracking(-0.8)
                        .foregroundStyle(t.ink)
                    + Text("Then decide.")
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .tracking(-0.8)
                        .foregroundStyle(t.accent))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                }
                .padding(.top, 30)
                .padding(.horizontal, 32)

                Spacer()

                // Breathing rings
                ZStack {
                    // Subtle radial glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [t.accent.opacity(0.08), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 140
                            )
                        )
                        .frame(width: 280, height: 280)

                    // Static outer ring
                    Circle()
                        .stroke(t.line, lineWidth: 1)
                        .frame(width: 260, height: 260)
                        .opacity(0.6)

                    // Animated breathing ring
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    t.accentSoft.opacity(0.4),
                                    t.accent.opacity(0.2),
                                    .clear,
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 110
                            )
                        )
                        .overlay(
                            Circle().stroke(t.accent, lineWidth: 1.5)
                        )
                        .frame(width: 220, height: 220)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    // Phase label + countdown
                    VStack(spacing: 6) {
                        Text(currentPhase.label)
                            .font(.system(size: 18, weight: .medium))
                            .tracking(-0.2)
                            .foregroundStyle(t.ink)

                        Text("\(secondsLeft)")
                            .font(.system(size: 36, weight: .thin, design: .monospaced))
                            .foregroundStyle(t.accent)
                    }
                }
                .frame(height: 300)

                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<3) { idx in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(idx == phaseIndex ? t.accent : t.line)
                            .frame(
                                width: idx == phaseIndex ? 24 : 6,
                                height: 6
                            )
                            .animation(
                                .easeInOut(duration: 0.3), value: phaseIndex
                            )
                    }
                }
                .padding(.top, 12)

                Spacer()

                // Encouragement
                Text("The urge will still be here in 12 seconds.\nSo will your power to choose.")
                    .font(.system(size: 13))
                    .italic()
                    .foregroundStyle(t.inkSoft)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 36)

                // CTA button
                Button { finish() } label: {
                    Text("I'm ready to choose")
                        .font(.system(size: 15, weight: .semibold))
                        .tracking(-0.2)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(t.accent)
                        .foregroundStyle(t.accentInk)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 16)
            }
            .opacity(fadeIn)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $navigateToWheel) {
            if let wheelID {
                WheelSpinnerView(wheelID: wheelID)
            }
        }
        .onAppear { startBreathing() }
        .onDisappear { timer?.invalidate() }
    }

    private func finish() {
        timer?.invalidate()
        if wheelID != nil {
            navigateToWheel = true
        } else {
            onComplete()
        }
    }

    private func startBreathing() {
        withAnimation(.easeIn(duration: 0.8)) { fadeIn = 1 }
        animateToPhase()
        secondsLeft = 4
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            tick()
        }
    }

    private func tick() {
        if secondsLeft > 1 {
            secondsLeft -= 1
        } else {
            let next = phaseIndex + 1
            if next >= BreathPhase.allCases.count {
                timer?.invalidate()
                finish()
            } else {
                phaseIndex = next
                secondsLeft = 4
                animateToPhase()
            }
        }
    }

    private func animateToPhase() {
        let phase = BreathPhase.allCases[phaseIndex]
        let dur: Double = phase == .hold ? 0.3 : 4.0
        withAnimation(.easeInOut(duration: dur)) {
            ringScale = phase.ringScale
            ringOpacity = phase == .hold ? 1.0 : 0.7
        }
    }
}

#Preview {
    NavigationStack {
        SpaceView(trigger: "Stress", onComplete: {})
    }
}
