//
//  SpaceView.swift
//  Choice Habbit App
//
//  Created by Joey Hansel on 25.04.26.
//

import SwiftUI

// The 4 phases of box breathing
enum BreathPhase: CaseIterable {
    case inhale, holdIn, exhale, holdOut

    var label: String {
        switch self {
        case .inhale:  return "Breathe In"
        case .holdIn:  return "Hold"
        case .exhale:  return "Breathe Out"
        case .holdOut: return "Hold"
        }
    }

    var duration: Double { 4.0 }

    var circleScale: CGFloat {
        switch self {
        case .inhale:  return 1.0
        case .holdIn:  return 1.0
        case .exhale:  return 0.4
        case .holdOut: return 0.4
        }
    }
}

struct SpaceView: View {
    let trigger: String
    var wheelID: UUID? = nil
    let onComplete: () -> Void

    @State private var phaseIndex: Int = 0
    @State private var circleScale: CGFloat = 0.4
    @State private var opacity: Double = 0
    @State private var secondsLeft: Int = 4
    @State private var timer: Timer? = nil
    @State private var navigateToWheel: Bool = false

    private var currentPhase: BreathPhase {
        BreathPhase.allCases[phaseIndex]
    }

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.12)
                .ignoresSafeArea()

            VStack(spacing: 40) {

                Text("Take a moment")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.5))
                    .opacity(opacity)

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.teal.opacity(0.15), lineWidth: 2)
                        .frame(width: 260, height: 260)

                    Circle()
                        .stroke(Color.teal.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 220, height: 220)
                        .scaleEffect(circleScale)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.teal.opacity(0.6),
                                    Color.teal.opacity(0.2)
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(circleScale)

                    VStack(spacing: 8) {
                        Text(currentPhase.label)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)

                        Text("\(secondsLeft)")
                            .font(.system(size: 42, weight: .thin, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .monospacedDigit()
                    }
                }
                .opacity(opacity)

                Spacer()

                HStack(spacing: 12) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(index == phaseIndex ? Color.teal : Color.white.opacity(0.2))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: phaseIndex)
                    }
                }
                .opacity(opacity)

                HStack(spacing: 0) {
                    ForEach(Array(BreathPhase.allCases.enumerated()), id: \.offset) { index, phase in
                        Text(phase.label)
                            .font(.caption2)
                            .foregroundColor(
                                index == phaseIndex
                                ? .teal
                                : .white.opacity(0.25)
                            )
                            .frame(maxWidth: .infinity)
                            .animation(.easeInOut(duration: 0.3), value: phaseIndex)
                    }
                }
                .opacity(opacity)
                .padding(.bottom, 40)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToWheel) {
            if let wheelID {
                WheelSpinnerView(wheelID: wheelID)
            }
        }
        .onAppear {
            startBreathing()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    func startBreathing() {
        withAnimation(.easeIn(duration: 0.8)) {
            opacity = 1
        }

        animateToCurrentPhase()

        secondsLeft = 4
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            tickTimer()
        }
    }

    func tickTimer() {
        if secondsLeft > 1 {
            secondsLeft -= 1
        } else {
            let nextIndex = phaseIndex + 1

            if nextIndex >= BreathPhase.allCases.count {
                timer?.invalidate()
                if wheelID != nil {
                    navigateToWheel = true
                } else {
                    onComplete()
                }
            } else {
                phaseIndex = nextIndex
                secondsLeft = 4
                animateToCurrentPhase()
            }
        }
    }

    func animateToCurrentPhase() {
        let phase = BreathPhase.allCases[phaseIndex]

        let animDuration: Double = {
            switch phase {
            case .inhale:  return 4.0
            case .exhale:  return 4.0
            case .holdIn, .holdOut: return 0.3
            }
        }()

        withAnimation(.easeInOut(duration: animDuration)) {
            circleScale = phase.circleScale
        }
    }
}

#Preview {
    NavigationStack {
        SpaceView(trigger: "Stress", onComplete: {})
    }
}
