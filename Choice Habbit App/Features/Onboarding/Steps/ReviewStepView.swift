import SwiftUI

struct ReviewStepView: View {
    let profile: OnboardingProfile
    let appData: AppData
    let onComplete: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Eyebrow(text: "YOUR PLAN", color: t.inkMute)
                    TideHeadline(
                        text: "Here's what we built\nfor you, \(profile.name).",
                        color: t.ink
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                VStack(spacing: 12) {
                    summaryCard(
                        icon: "xmark.circle",
                        title: "Habits to break",
                        items: Array(profile.selectedBadHabits).sorted()
                    )

                    summaryCard(
                        icon: "bolt",
                        title: "Triggers identified",
                        items: Array(profile.selectedTriggers).sorted()
                    )

                    worldviewCard

                    wheelsCard
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                Spacer(minLength: 120)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Button(action: onComplete) {
                    Text("Looks good — let's go")
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
            .background(t.bg)
        }
    }

    // MARK: - Summary Card

    private func summaryCard(
        icon: String,
        title: String,
        items: [String]
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(t.accent)

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(t.ink)

                Spacer()

                Text("\(items.count)")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(t.inkMute)
            }

            Text(items.joined(separator: " · "))
                .font(.system(size: 13))
                .foregroundStyle(t.inkSoft)
                .lineSpacing(4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(t.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(t.line, lineWidth: 1)
                )
        )
    }

    // MARK: - Worldview Card

    private var worldviewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: profile.worldview?.icon ?? "questionmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(t.accent)

                Text("Personalization")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(t.ink)
            }

            Text(worldviewDescription)
                .font(.system(size: 13))
                .foregroundStyle(t.inkSoft)
                .lineSpacing(4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(t.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(t.line, lineWidth: 1)
                )
        )
    }

    private var worldviewDescription: String {
        switch profile.worldview {
        case .religious:
            let faith = profile.faithDetail?.displayName ?? "your faith"
            return "\(faith) practices added to your wheels — prayer, scripture, and tradition-specific alternatives."
        case .spiritual:
            return "Spiritual practices added — yoga, breathwork, visualization, affirmations, and grounding exercises."
        case .secular:
            return "Evidence-based secular alternatives — mindfulness, exercise, journaling, and cognitive techniques."
        case .preferNotToSay, .none:
            return "General wellness alternatives — mindfulness, exercise, journaling, and grounding techniques."
        }
    }

    // MARK: - Wheels Preview

    private var wheelsCard: some View {
        let wheelNames = profile.selectedTriggers.sorted().map {
            wheelName(for: $0)
        }

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "circle.grid.cross")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(t.accent)

                Text("Wheels created")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(t.ink)

                Spacer()

                Text("\(wheelNames.count)")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(t.inkMute)
            }

            Text(wheelNames.joined(separator: " · "))
                .font(.system(size: 13))
                .foregroundStyle(t.inkSoft)
                .lineSpacing(4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(t.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(t.line, lineWidth: 1)
                )
        )
    }

    private func wheelName(for trigger: String) -> String {
        switch trigger {
        case "Boredom": return "Boredom Busters"
        case "Stress": return "Stress Relief"
        case "Anxiety": return "Calm & Ground"
        case "Anger": return "Cool Down"
        case "Loneliness": return "Connection"
        case "Arousal": return "Redirect Energy"
        case "Procrastination": return "Quick Starts"
        case "Sadness": return "Lift Your Spirits"
        default: return "\(trigger) Relief"
        }
    }
}
