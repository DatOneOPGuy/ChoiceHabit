import SwiftUI

struct FaithDetailStepView: View {
    let profile: OnboardingProfile
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Eyebrow(text: "YOUR FAITH", color: t.inkMute)
                TideHeadline(text: "Which tradition?", color: t.ink)
                Text("We'll add faith-specific practices to your wheels.")
                    .font(.system(size: 14))
                    .foregroundStyle(t.inkSoft)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)

            VStack(spacing: 6) {
                ForEach(FaithDetail.allCases, id: \.self) { faith in
                    faithRow(faith)
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
                    .background(
                        profile.faithDetail == nil ? t.line : t.accent
                    )
                    .foregroundStyle(
                        profile.faithDetail == nil ? t.inkMute : t.accentInk
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(profile.faithDetail == nil)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    @ViewBuilder
    private func faithRow(_ faith: FaithDetail) -> some View {
        let selected = profile.faithDetail == faith
        Button {
            profile.faithDetail = faith
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(selected ? t.accent : t.surface)
                        .frame(width: 38, height: 38)

                    Circle()
                        .stroke(selected ? t.accent : t.line, lineWidth: 0.5)
                        .frame(width: 38, height: 38)

                    Text(String(faith.displayName.prefix(1)))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(selected ? t.accentInk : t.accent)
                }

                Text(faith.displayName)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(t.ink)

                Spacer()

                if selected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(t.accent)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(selected ? t.accentSoft.opacity(0.12) : Color.clear)
            )
        }
    }
}
