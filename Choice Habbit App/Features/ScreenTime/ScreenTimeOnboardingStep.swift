import SwiftUI
import FamilyControls

struct ScreenTimeOnboardingStep: View {
    let profile: OnboardingProfile
    let onContinue: () -> Void

    @State private var manager = ScreenTimeManager()
    @State private var authorized = false
    @State private var activitySelection = FamilyActivitySelection()
    @State private var showingPicker = false
    @State private var timeLimitMinutes = 30

    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    private let presetLimits = [15, 30, 60, 120]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        Eyebrow(text: "SMART REMINDERS", color: t.inkMute)
                        TideHeadline(
                            text: "Stay aware of your\nscreen time.",
                            color: t.ink
                        )
                        Text("Instead can notice when you've been on certain apps too long and remind you to choose differently.")
                            .font(.system(size: 14))
                            .foregroundStyle(t.inkSoft)
                            .padding(.top, 6)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)

                    if !authorized {
                        authSection
                    } else {
                        quickSetupSection
                    }

                    Spacer(minLength: 120)
                }
            }

            VStack(spacing: 10) {
                Button(action: continueWithSetup) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(t.accent)
                        .foregroundStyle(t.accentInk)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Button(action: onContinue) {
                    Text("Skip for now")
                        .font(.system(size: 15))
                        .foregroundStyle(t.inkMute)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Auth Section

    private var authSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "hourglass.circle")
                .font(.system(size: 48))
                .foregroundStyle(t.accent)

            Text("To monitor app usage, Instead needs your permission to access Screen Time data.")
                .font(.system(size: 14))
                .foregroundStyle(t.inkSoft)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Button {
                Task {
                    authorized = await manager.requestAuthorization()
                }
            } label: {
                Label("Enable App Monitoring", systemImage: "checkmark.shield")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(t.accent)
                    .foregroundStyle(t.accentInk)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(t.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(t.line, lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }

    // MARK: - Quick Setup

    private var quickSetupSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Success badge
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(t.ok)
                Text("Screen Time access enabled")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(t.ink)
            }
            .padding(.top, 24)

            // App picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose apps to monitor")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(t.inkMute)

                Button { showingPicker = true } label: {
                    HStack {
                        Image(systemName: "apps.iphone")
                            .foregroundStyle(t.accent)
                        let count = activitySelection.applicationTokens.count
                            + activitySelection.categoryTokens.count
                        Text(count > 0
                            ? "\(count) apps selected"
                            : "Select apps")
                            .font(.system(size: 15))
                            .foregroundStyle(count > 0 ? t.ink : t.inkMute)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13))
                            .foregroundStyle(t.inkMute)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(t.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(t.line, lineWidth: 1)
                            )
                    )
                }
            }

            // Time limit
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily time limit")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(t.inkMute)

                HStack(spacing: 8) {
                    ForEach(presetLimits, id: \.self) { mins in
                        let selected = timeLimitMinutes == mins
                        Button { timeLimitMinutes = mins } label: {
                            Text(mins < 60 ? "\(mins)m" : "\(mins / 60)h")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(selected ? t.accent : t.ink)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selected
                                            ? t.accentSoft.opacity(0.15)
                                            : t.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selected
                                                    ? t.accent : t.line,
                                                    lineWidth: selected ? 1.5 : 1
                                                )
                                        )
                                )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .familyActivityPicker(
            isPresented: $showingPicker,
            selection: $activitySelection
        )
    }

    private func continueWithSetup() {
        if authorized,
           !activitySelection.applicationTokens.isEmpty
            || !activitySelection.categoryTokens.isEmpty {
            let selectionData = try? JSONEncoder().encode(activitySelection)
            let rule = AppLimitRule(
                name: "My first limit",
                activitySelectionData: selectionData,
                timeLimitMinutes: timeLimitMinutes,
                activeDays: Set(1...7)
            )
            manager.addRule(rule)
            manager.toggleMonitoring(true)
        }
        onContinue()
    }
}

#Preview {
    ScreenTimeOnboardingStep(profile: OnboardingProfile()) {}
}
