import SwiftUI

struct TriggersStepView: View {
    let profile: OnboardingProfile
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        Eyebrow(text: "KNOW YOUR TRIGGERS", color: t.inkMute)
                        TideHeadline(text: "What sets you off?", color: t.ink)
                        Text("When do you usually reach for bad habits?")
                            .font(.system(size: 14))
                            .foregroundStyle(t.inkSoft)
                            .padding(.top, 2)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(OnboardingConstants.triggerOptions, id: \.self) { trigger in
                            chipButton(trigger)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 120)
                }
            }

            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        profile.selectedTriggers.isEmpty ? t.line : t.accent
                    )
                    .foregroundStyle(
                        profile.selectedTriggers.isEmpty ? t.inkMute : t.accentInk
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(profile.selectedTriggers.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }

    @ViewBuilder
    private func chipButton(_ label: String) -> some View {
        let selected = profile.selectedTriggers.contains(label)
        Button {
            if selected {
                profile.selectedTriggers.remove(label)
            } else {
                profile.selectedTriggers.insert(label)
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

#Preview {
    TriggersStepView(profile: OnboardingProfile()) {}
}
