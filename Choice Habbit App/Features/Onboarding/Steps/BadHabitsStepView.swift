import SwiftUI

struct BadHabitsStepView: View {
    let profile: OnboardingProfile
    let onContinue: () -> Void

    @State private var customHabit = ""
    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Eyebrow(text: "BE HONEST WITH YOURSELF", color: t.inkMute)
                    TideHeadline(text: "What do you want\nto change?", color: t.ink)
                    Text("Select everything that applies.")
                        .font(.system(size: 14))
                        .foregroundStyle(t.inkSoft)
                        .padding(.top, 2)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(OnboardingConstants.badHabitOptions, id: \.self) { habit in
                        chipButton(habit)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                // Custom option
                HStack(spacing: 10) {
                    TextField("Other...", text: $customHabit)
                        .font(.system(size: 15))
                        .foregroundStyle(t.ink)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(t.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(t.line, lineWidth: 1)
                                )
                        )

                    if !customHabit.trimmingCharacters(in: .whitespaces).isEmpty {
                        Button {
                            let trimmed = customHabit.trimmingCharacters(in: .whitespaces)
                            profile.selectedBadHabits.insert(trimmed)
                            customHabit = ""
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(t.accent)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)

                Spacer(minLength: 100)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        profile.selectedBadHabits.isEmpty ? t.line : t.accent
                    )
                    .foregroundStyle(
                        profile.selectedBadHabits.isEmpty ? t.inkMute : t.accentInk
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(profile.selectedBadHabits.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .background(t.bg)
        }
    }

    @ViewBuilder
    private func chipButton(_ label: String) -> some View {
        let selected = profile.selectedBadHabits.contains(label)
        Button {
            if selected {
                profile.selectedBadHabits.remove(label)
            } else {
                profile.selectedBadHabits.insert(label)
            }
        } label: {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(selected ? t.accent : t.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(selected ? t.accentSoft.opacity(0.15) : t.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    selected ? t.accent : t.line,
                                    lineWidth: selected ? 1.5 : 1
                                )
                        )
                )
        }
    }
}
