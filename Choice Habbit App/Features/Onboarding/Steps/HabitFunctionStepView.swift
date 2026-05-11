import SwiftUI

struct HabitFunctionStepView: View {
    let profile: OnboardingProfile
    let onComplete: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    @State private var currentHabitIndex = 0

    private var habits: [String] {
        profile.selectedBadHabits.sorted()
    }

    private var currentHabit: String? {
        guard currentHabitIndex < habits.count else { return nil }
        return habits[currentHabitIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            if let habit = currentHabit {
                Spacer()

                VStack(spacing: 20) {
                    Text("When does \(habit) mostly happen?")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(t.ink)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    VStack(spacing: 10) {
                        ForEach(HabitFunction.allCases, id: \.self) { function in
                            let selected = profile.habitFunctions[habit] == function
                            Button {
                                profile.habitFunctions[habit] = function
                            } label: {
                                Text("When I'm \(function.rawValue.lowercased())")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(selected ? t.accentInk : t.ink)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(selected ? t.accent : t.surfaceAlt)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(t.line, lineWidth: 0.5)
                                            )
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 32)

                    Button { advanceHabit(skip: true) } label: {
                        Text("Not sure \u{2192}")
                            .font(.system(size: 14))
                            .foregroundStyle(t.inkSoft)
                    }
                }

                Spacer()

                if profile.habitFunctions[habit] != nil {
                    Button { advanceHabit(skip: false) } label: {
                        Text(currentHabitIndex < habits.count - 1 ? "Next \u{2192}" : "Continue \u{2192}")
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(t.accent)
                            .foregroundStyle(t.accentInk)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }

                if habits.count > 1 {
                    Text("\(currentHabitIndex + 1) of \(habits.count)")
                        .font(.system(size: 12))
                        .foregroundStyle(t.inkMute)
                        .padding(.bottom, 16)
                }
            }
        }
    }

    private func advanceHabit(skip: Bool) {
        if let habit = currentHabit, skip {
            profile.habitFunctions[habit] = .boredom
        }
        if currentHabitIndex < habits.count - 1 {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentHabitIndex += 1
            }
        } else {
            onComplete()
        }
    }
}
