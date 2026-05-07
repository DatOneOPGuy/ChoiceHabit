import SwiftUI

struct SettingsView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("themeChoice") private var themeChoice: String = ThemeChoice.auto.rawValue
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("soundsEnabled") private var soundsEnabled = true
    @AppStorage("userName") private var userName = ""
    @AppStorage("worldview") private var worldviewRaw = ""
    @AppStorage("onboardingCompleted") private var onboardingCompleted = true
    private var t: Tide { .resolve(colorScheme) }

    @State private var showingRedoAlert = false

    private var wheelCount: Int { appData.wheels.count }

    private var optionCount: Int {
        appData.wheels.reduce(0) { $0 + $1.options.count }
    }

    private var themeLabel: String {
        switch ThemeChoice(rawValue: themeChoice) {
        case .light: return "Light"
        case .dark: return "Dark"
        default: return "System default"
        }
    }

    @State private var showingManifesto = false
    @State private var showingPrivacy = false

    var body: some View {
        VStack(spacing: 0) {
            TopBar(leading: .menu) {}

            ScrollView {
                VStack(spacing: 0) {
                    header
                    groupedSections
                }
                .padding(.bottom, 40)
            }
        }
        .background(t.bg.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingManifesto) {
            ManifestoView()
        }
        .sheet(isPresented: $showingPrivacy) {
            PrivacyView()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Eyebrow(text: "SETTINGS", color: t.inkMute)
            TideHeadline(text: "Tend the practice.", color: t.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 18)
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    // MARK: - Grouped Sections

    private var groupedSections: some View {
        VStack(spacing: 0) {
            if !userName.isEmpty {
                settingsGroup(title: "PROFILE") {
                    profileRows
                }
            }
            settingsGroup(title: "PRACTICE") {
                practiceRows
            }
            settingsGroup(title: "EXPERIENCE") {
                experienceRows
            }
            settingsGroup(title: "ABOUT") {
                aboutRows
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 16)
        .alert("Redo Onboarding?", isPresented: $showingRedoAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset & Redo", role: .destructive) {
                appData.clearAll()
                userName = ""
                worldviewRaw = ""
                UserDefaults.standard.removeObject(forKey: "faithDetail")
                onboardingCompleted = false
            }
        } message: {
            Text("This will clear your wheels, triggers, and bad habits. Your session history will also be cleared.")
        }
    }

    // MARK: - Profile Rows

    @ViewBuilder
    private var profileRows: some View {
        let worldviewName = Worldview(rawValue: worldviewRaw)?.displayName ?? ""

        settingsRowContent(
            icon: "person",
            label: userName,
            sub: worldviewName.isEmpty ? "Tap to redo onboarding" : worldviewName
        )
    }

    // MARK: - Practice Rows

    @ViewBuilder
    private var practiceRows: some View {
        NavigationLink { HabitPairListView() } label: {
            settingsRowContent(
                icon: "bolt",
                label: "Triggers",
                sub: "\(appData.habitPairs.count) active triggers"
            )
        }

        Divider().overlay(t.line)

        NavigationLink { WheelListView() } label: {
            settingsRowContent(
                icon: "circle.grid.cross",
                label: "Wheels",
                sub: "\(wheelCount) wheels \u{00B7} \(optionCount) options"
            )
        }

        Divider().overlay(t.line)

        NavigationLink { BadHabitListView() } label: {
            settingsRowContent(
                icon: "xmark.circle",
                label: "Bad habits",
                sub: "\(appData.badHabits.count) to replace"
            )
        }

        Divider().overlay(t.line)

        Button { showingRedoAlert = true } label: {
            settingsRowContent(
                icon: "arrow.counterclockwise",
                label: "Redo onboarding",
                sub: "Reset your profile and wheels"
            )
        }
    }

    // MARK: - Experience Rows

    @ViewBuilder
    private var experienceRows: some View {
        // Theme picker
        Menu {
            ForEach(ThemeChoice.allCases, id: \.self) { choice in
                Button {
                    themeChoice = choice.rawValue
                } label: {
                    HStack {
                        Text(choice.displayName)
                        if themeChoice == choice.rawValue {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            settingsRowContent(
                icon: "circle.lefthalf.filled",
                label: "Theme",
                sub: themeLabel
            )
        }

        Divider().overlay(t.line)

        // Notifications toggle
        settingsToggleRow(
            icon: "bell",
            label: "Notifications",
            sub: "Background timer alerts",
            isOn: $notificationsEnabled
        )

        Divider().overlay(t.line)

        // Sounds toggle
        settingsToggleRow(
            icon: "speaker.wave.2",
            label: "Sounds & haptics",
            sub: "Soft tones on actions",
            isOn: $soundsEnabled
        )
    }

    // MARK: - About Rows

    @ViewBuilder
    private var aboutRows: some View {
        Button { showingManifesto = true } label: {
            settingsRowContent(
                icon: "info.circle",
                label: "Why Instead",
                sub: "Read the manifesto"
            )
        }

        Divider().overlay(t.line)

        Button { showingPrivacy = true } label: {
            settingsRowContent(
                icon: "lock",
                label: "Privacy",
                sub: "Everything stays on your phone"
            )
        }
    }

    // MARK: - Settings Group Container

    private func settingsGroup<Content: View>(
        title: String,
        @ViewBuilder rows: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.5)
                .textCase(.uppercase)
                .foregroundStyle(t.inkMute)
                .padding(.top, 8)
                .padding(.bottom, 6)
                .padding(.horizontal, 10)

            VStack(spacing: 0) {
                rows()
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(t.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(t.line, lineWidth: 1)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.bottom, 10)
    }

    // MARK: - Row Content

    private func settingsRowContent(
        icon: String,
        label: String,
        sub: String
    ) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(t.surfaceAlt)
                .frame(width: 34, height: 34)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .imageScale(.medium)
                        .foregroundStyle(t.accent)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 15))
                    .foregroundStyle(t.ink)
                Text(sub)
                    .font(.system(size: 12))
                    .foregroundStyle(t.inkMute)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(t.inkMute)
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 14)
        .contentShape(Rectangle())
    }

    // MARK: - Toggle Row

    private func settingsToggleRow(
        icon: String,
        label: String,
        sub: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(t.surfaceAlt)
                .frame(width: 34, height: 34)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .imageScale(.medium)
                        .foregroundStyle(t.accent)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 15))
                    .foregroundStyle(t.ink)
                Text(sub)
                    .font(.system(size: 12))
                    .foregroundStyle(t.inkMute)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(t.accent)
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 14)
    }
}

// MARK: - Theme Display Name

extension ThemeChoice {
    var displayName: String {
        switch self {
        case .auto: return "System default"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

// MARK: - Manifesto View

struct ManifestoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Why Instead")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(t.ink)

                    Group {
                        Text("Every habit starts with a trigger.")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(t.ink)

                        Text("Boredom. Stress. Anxiety. Anger. The feeling rises, and before you know it, you're reaching for the phone, the snack, the thing you promised yourself you'd stop doing.")
                            .foregroundStyle(t.inkSoft)

                        Text("Instead doesn't fight the trigger — it redirects it.")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(t.accent)

                        Text("When you feel the urge, you pause. You breathe. Then you spin the wheel and let it choose a better path for you. Push-ups instead of scrolling. A walk instead of stress eating. Journaling instead of overthinking.")
                            .foregroundStyle(t.inkSoft)

                        Text("The wheel is weighted by what works. The more an action helps, the more likely it comes up again. Over time, Instead learns your rhythm.")
                            .foregroundStyle(t.inkSoft)

                        Text("This isn't about willpower.")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(t.ink)

                        Text("It's about making the better choice the easier choice. One spin at a time.")
                            .foregroundStyle(t.inkSoft)
                    }
                    .font(.system(size: 15))
                    .lineSpacing(4)
                }
                .padding(24)
            }
            .background(t.bg.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(t.accent)
                }
            }
        }
    }
}

// MARK: - Privacy View

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(t.ink)

                    Group {
                        Text("Your data never leaves your device.")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(t.accent)

                        Text("Instead stores everything locally on your iPhone. Your triggers, habits, wheel configurations, and session history are saved as a simple file on your device — not in the cloud, not on a server, not anywhere else.")
                            .foregroundStyle(t.inkSoft)

                        Text("No accounts. No sign-ups. No tracking.")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(t.ink)

                        Text("We don't collect analytics, usage data, or personal information of any kind. There are no ads, no third-party SDKs, and no network requests. The app works entirely offline.")
                            .foregroundStyle(t.inkSoft)

                        Text("If you delete the app, your data is gone. That's it. No residual data, no backups on our end — because there is no \"our end.\"")
                            .foregroundStyle(t.inkSoft)

                        Text("Your habits are yours. Period.")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(t.ink)
                    }
                    .font(.system(size: 15))
                    .lineSpacing(4)
                }
                .padding(24)
            }
            .background(t.bg.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(t.accent)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(AppData.sample())
}
