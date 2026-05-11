import SwiftUI

struct TriggerListView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("userName") private var userName = ""
    @AppStorage("hasSeenFirstBreathing") private var hasSeenFirstBreathing = false
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    private var t: Tide { .resolve(colorScheme) }

    @State private var showBreathing = false
    @State private var showSlipEntry = false
    @State private var bannerDismissed = false

    var isLateNight: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 0 && hour < 4
    }

    var body: some View {
        VStack(spacing: 0) {
            TopBar(leading: .menu) {}

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if isLateNight && !bannerDismissed {
                        lateNightBanner
                    }

                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            TideHeadline(
                                text: userName.isEmpty
                                    ? "What do you\nfeel right now?"
                                    : "What do you feel\nright now, \(userName)?",
                                color: t.ink
                            )
                            .lineSpacing(-2)

                            Text("Pause. Notice the trigger. Choose a different path.")
                                .font(.system(size: 14))
                                .foregroundStyle(t.inkSoft)
                                .frame(maxWidth: 280, alignment: .leading)
                                .padding(.top, 2)
                        }

                        Spacer()

                        Button { showBreathing = true } label: {
                            Text("Breathe")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(t.inkSoft)
                        }
                        .padding(.top, 6)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                    if appData.habitPairs.isEmpty {
                        ContentUnavailableView(
                            "No Triggers Yet",
                            systemImage: "list.bullet",
                            description: Text("Go to Settings to add your first trigger.")
                        )
                        .foregroundStyle(t.inkSoft)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(Array(appData.habitPairs.enumerated()), id: \.element.id) { index, pair in
                                NavigationLink(destination: WheelSpinnerView(
                                    wheelID: pair.parentWheelID,
                                    trigger: pair.trigger,
                                    oldHabit: pair.oldHabit
                                )) {
                                    triggerRow(pair: pair, isFirst: index == 0)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)

                        Button { showSlipEntry = true } label: {
                            Text("I already did it \u{2192}")
                                .font(.system(size: 14))
                                .foregroundStyle(t.inkSoft)
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 24)
                    }
                }
            }
        }
        .background(t.bg.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showBreathing) {
            NavigationStack {
                SpaceView(trigger: "") {
                    showBreathing = false
                }
            }
        }
        .sheet(isPresented: $showSlipEntry) {
            SlipEntryView()
                .environment(appData)
        }
        .onAppear {
            if onboardingCompleted && !hasSeenFirstBreathing {
                hasSeenFirstBreathing = true
                showBreathing = true
            }
        }
    }

    // MARK: - Late Night Banner

    private var lateNightBanner: some View {
        Button { bannerDismissed = true } label: {
            Text("It's past midnight. Your brain is working against you right now — keep the action small.")
                .font(.system(size: 13))
                .foregroundStyle(t.ink)
                .multilineTextAlignment(.leading)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(t.warm.opacity(0.15))
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func triggerRow(pair: HabitPair, isFirst: Bool) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(t.surface)
                    .frame(width: 38, height: 38)

                Circle()
                    .stroke(t.line, lineWidth: 0.5)
                    .frame(width: 38, height: 38)

                Text(String(pair.trigger.prefix(1)).uppercased())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(t.accent)
            }

            Text(pair.trigger)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(t.ink)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(t.inkMute)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isFirst ? t.surfaceAlt : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isFirst ? t.line : Color.clear, lineWidth: 0.5)
                )
        )
    }
}

#Preview {
    NavigationStack {
        TriggerListView()
    }
    .environment(AppData.sample())
}
