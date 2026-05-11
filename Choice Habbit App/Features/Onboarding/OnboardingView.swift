import SwiftUI

struct OnboardingView: View {
    let appData: AppData
    let onComplete: () -> Void

    @State private var profile = OnboardingProfile()
    @State private var currentStep = 0

    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    private var steps: [OnboardingStep] {
        var s: [OnboardingStep] = [
            .welcome, .name, .badHabits, .habitFunction, .worldview
        ]
        if profile.worldview == .religious {
            s.append(.faithDetail)
        }
        s.append(contentsOf: [.triggers, .review])
        return s
    }

    private var currentStepType: OnboardingStep {
        guard currentStep < steps.count else { return .review }
        return steps[currentStep]
    }

    var body: some View {
        ZStack {
            t.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                Group {
                    switch currentStepType {
                    case .welcome:
                        WelcomeStepView { advance() }
                    case .name:
                        NameStepView(profile: profile) { advance() }
                    case .badHabits:
                        BadHabitsStepView(profile: profile) { advance() }
                    case .habitFunction:
                        HabitFunctionStepView(profile: profile) { advance() }
                    case .worldview:
                        WorldviewStepView(profile: profile) { advance() }
                    case .faithDetail:
                        FaithDetailStepView(profile: profile) { advance() }
                    case .triggers:
                        TriggersStepView(profile: profile) { advance() }
                    case .review:
                        ReviewStepView(
                            profile: profile,
                            appData: appData,
                            onComplete: finishOnboarding
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(currentStepType)

                Spacer(minLength: 0)

                if currentStep > 0 {
                    progressDots
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: currentStepType)
    }

    // MARK: - Progress Dots

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<steps.count, id: \.self) { idx in
                RoundedRectangle(cornerRadius: 3)
                    .fill(idx == currentStep ? t.accent : t.line)
                    .frame(
                        width: idx == currentStep ? 24 : 6,
                        height: 6
                    )
            }
        }
        .padding(.bottom, 24)
        .animation(.easeInOut(duration: 0.3), value: currentStep)
    }

    // MARK: - Navigation

    private func advance() {
        withAnimation(.easeInOut(duration: 0.35)) {
            currentStep += 1
        }
    }

    private func finishOnboarding() {
        UserDefaults.standard.set(profile.name, forKey: "userName")
        UserDefaults.standard.set(
            profile.worldview?.rawValue ?? "",
            forKey: "worldview"
        )
        UserDefaults.standard.set(
            profile.faithDetail?.rawValue ?? "",
            forKey: "faithDetail"
        )

        WheelBuilder.populate(appData, profile: profile)
        onComplete()
    }
}

// MARK: - Step Enum

enum OnboardingStep: Hashable {
    case welcome, name, badHabits, habitFunction, worldview, faithDetail, triggers, review
}

#Preview {
    OnboardingView(appData: AppData.sample()) {}
}
