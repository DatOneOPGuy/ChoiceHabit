import SwiftUI

struct WelcomeStepView: View {
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                // App icon placeholder
                ZStack {
                    Circle()
                        .fill(t.accent.opacity(0.12))
                        .frame(width: 100, height: 100)

                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(t.accent)
                }

                Text("Instead")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(t.ink)

                Text("Replace bad habits\nwith better choices.")
                    .font(.system(size: 17))
                    .foregroundStyle(t.inkSoft)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Spacer()

            Button(action: onContinue) {
                Text("Get Started")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(t.accent)
                    .foregroundStyle(t.accentInk)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}
