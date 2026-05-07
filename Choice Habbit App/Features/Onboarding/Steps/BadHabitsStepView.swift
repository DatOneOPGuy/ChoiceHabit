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

    private var customHabits: [String] {
        profile.selectedBadHabits
            .filter { !OnboardingConstants.badHabitOptions.contains($0) }
            .sorted()
    }

    var body: some View {
        VStack(spacing: 0) {
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
                    .padding(.top, 40)

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(OnboardingConstants.badHabitOptions, id: \.self) { habit in
                            chipButton(habit)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    // Show custom-added habits
                    if !customHabits.isEmpty {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(customHabits, id: \.self) { habit in
                                customChip(habit)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                    }

                    // Custom input
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
                            .onSubmit { addCustomHabit() }

                        Button(action: addCustomHabit) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(
                                    customHabit.trimmingCharacters(in: .whitespaces).isEmpty
                                        ? t.inkMute : t.accent
                                )
                        }
                        .disabled(customHabit.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 120)
                }
            }

            // Continue button pinned at bottom
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
            .padding(.bottom, 16)
        }
    }

    private func addCustomHabit() {
        let trimmed = customHabit.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        profile.selectedBadHabits.insert(trimmed)
        customHabit = ""
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

    @ViewBuilder
    private func customChip(_ label: String) -> some View {
        Button {
            profile.selectedBadHabits.remove(label)
        } label: {
            HStack(spacing: 6) {
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundStyle(t.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(t.accentSoft.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(t.accent, lineWidth: 1.5)
                    )
            )
        }
    }
}

#Preview {
    BadHabitsStepView(profile: OnboardingProfile()) {}
}
