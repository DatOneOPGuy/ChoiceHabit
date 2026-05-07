import SwiftUI

struct WorldviewStepView: View {
    let profile: OnboardingProfile
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Eyebrow(text: "YOUR WORLDVIEW", color: t.inkMute)
                TideHeadline(text: "How do you see\nthe world?", color: t.ink)
                Text("This helps us personalize your alternatives.")
                    .font(.system(size: 14))
                    .foregroundStyle(t.inkSoft)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)

            VStack(spacing: 10) {
                ForEach(Worldview.allCases, id: \.self) { option in
                    worldviewCard(option)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            Spacer()

            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(profile.worldview == nil ? t.line : t.accent)
                    .foregroundStyle(profile.worldview == nil ? t.inkMute : t.accentInk)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(profile.worldview == nil)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    @ViewBuilder
    private func worldviewCard(_ option: Worldview) -> some View {
        let selected = profile.worldview == option
        Button {
            profile.worldview = option
        } label: {
            HStack(spacing: 14) {
                Image(systemName: option.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(selected ? t.accent : t.inkSoft)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(t.ink)
                }

                Spacer()

                Circle()
                    .fill(selected ? t.accent : Color.clear)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(selected ? t.accent : t.line, lineWidth: 1.5)
                    )
                    .overlay(
                        selected
                            ? Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(t.accentInk)
                            : nil
                    )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selected ? t.accentSoft.opacity(0.12) : t.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selected ? t.accent : t.line, lineWidth: selected ? 1.5 : 1)
                    )
            )
        }
    }
}
