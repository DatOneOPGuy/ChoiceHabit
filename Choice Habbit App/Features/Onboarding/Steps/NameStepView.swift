import SwiftUI

struct NameStepView: View {
    let profile: OnboardingProfile
    let onContinue: () -> Void

    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Eyebrow(text: "LET'S GET TO KNOW YOU", color: t.inkMute)
                TideHeadline(text: "What should we\ncall you?", color: t.ink)
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)

            TextField("Your name", text: Bindable(profile).name)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(t.ink)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(t.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(t.line, lineWidth: 1)
                        )
                )
                .focused($isFocused)
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .onAppear { isFocused = true }

            Spacer()

            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        profile.name.trimmingCharacters(in: .whitespaces).isEmpty
                            ? t.line : t.accent
                    )
                    .foregroundStyle(
                        profile.name.trimmingCharacters(in: .whitespaces).isEmpty
                            ? t.inkMute : t.accentInk
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(profile.name.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}
