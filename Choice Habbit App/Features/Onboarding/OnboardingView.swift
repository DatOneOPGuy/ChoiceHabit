import SwiftUI

struct OnboardingView: View {
    let appData: AppData
    let onComplete: () -> Void

    @State private var profile = OnboardingProfile()
    @State private var currentStep = 0

    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    private var totalSteps: Int {
        profile.worldview == .religious ? 7 : 6
    }

    private var showsFaithStep: Bool {
        profile.worldview == .religious
    }

    var body: some View {
        ZStack {
            t.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Step content
                Group {
                    switch currentStep {
                    case 0:
                        WelcomeStepView { advance() }
                    case 1:
                        NameStepView(profile: profile) { advance() }
                    case 2:
                        BadHabitsStepView(profile: profile) { advance() }
                    case 3:
                        WorldviewStepView(profile: profile) { advance() }
                    case 4 where showsFaithStep:
                        FaithDetailStepView(profile: profile) { advance() }
                    case 4 where !showsFaithStep:
                        TriggersStepView(profile: profile) { advance() }
                    case 5 where showsFaithStep:
                        TriggersStepView(profile: profile) { advance() }
                    case 5 where !showsFaithStep:
                        ReviewStepView(
                            profile: profile,
                            appData: appData,
                            onComplete: finishOnboarding
                        )
                    case 6:
                        ReviewStepView(
                            profile: profile,
                            appData: appData,
                            onComplete: finishOnboarding
                        )
                    default:
                        EmptyView()
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: currentStep)

                Spacer(minLength: 0)

                // Progress dots
                if currentStep > 0 {
                    progressDots
                }
            }
        }
    }

    // MARK: - Progress Dots

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { idx in
                RoundedRectangle(cornerRadius: 3)
                    .fill(idx == currentStep ? t.accent : t.line)
                    .frame(
                        width: idx == currentStep ? 24 : 6,
                        height: 6
                    )
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .padding(.bottom, 24)
    }

    // MARK: - Navigation

    private func advance() {
        withAnimation { currentStep += 1 }
    }

    func goBack() {
        guard currentStep > 0 else { return }
        withAnimation { currentStep -= 1 }
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
