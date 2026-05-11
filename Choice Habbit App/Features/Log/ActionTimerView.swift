import SwiftUI
import UserNotifications

struct ActionTimerView: View {
    let action: String
    let trigger: String
    let oldHabit: String

    @Environment(AppData.self) private var appData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    @State private var isRunning = false
    @State private var startTime: Date? = nil
    @State private var elapsedSeconds = 0
    @State private var timerTask: Timer? = nil
    @State private var showingSuccess = false
    @State private var savedEntry: LogEntry? = nil
    @State private var hasShownReframe = false
    @State private var didntWorkConfirmation = false

    private var timeString: String {
        let hours   = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private var markerThreshold: Int {
        switch appData.currentEnergyLevel {
        case .fine: return 90
        case .strained: return 60
        case .empty: return 45
        }
    }

    private var ringProgress: Double {
        guard markerThreshold > 0 else { return 1.0 }
        return min(1.0, Double(elapsedSeconds) / Double(markerThreshold))
    }

    private var markerComplete: Bool {
        elapsedSeconds >= markerThreshold
    }

    private static let confirmationPhrases = [
        "That's a redirect. It counts.",
        "You changed the pattern just now.",
        "The urge passed. You helped it along.",
        "Small move. Real shift.",
        "That's what it looks like.",
    ]

    @AppStorage("lastPhraseIndices") private var lastPhraseIndicesData: String = ""

    private var confirmationPhrase: String {
        let used = lastPhraseIndicesData.split(separator: ",").compactMap { Int($0) }
        let available = (0..<Self.confirmationPhrases.count).filter { !used.contains($0) }
        let index = available.randomElement() ?? Int.random(in: 0..<Self.confirmationPhrases.count)
        return Self.confirmationPhrases[index]
    }

    private func recordPhraseIndex(_ phrase: String) {
        guard let index = Self.confirmationPhrases.firstIndex(of: phrase) else { return }
        var used = lastPhraseIndicesData.split(separator: ",").compactMap { Int($0) }
        used.append(index)
        if used.count > 4 { used.removeFirst() }
        lastPhraseIndicesData = used.map(String.init).joined(separator: ",")
    }

    private func triggerRedirectsThisMonth() -> Int {
        let cal = Calendar.current
        let now = Date()
        return appData.logEntries.filter {
            $0.trigger == trigger && cal.isDate($0.date, equalTo: now, toGranularity: .month)
        }.count
    }

    private func triggerRedirectsLastMonth() -> Int? {
        let cal = Calendar.current
        guard let lastMonth = cal.date(byAdding: .month, value: -1, to: Date()) else { return nil }
        let count = appData.logEntries.filter {
            $0.trigger == trigger && cal.isDate($0.date, equalTo: lastMonth, toGranularity: .month)
        }.count
        return count > 0 ? count : nil
    }

    private var formattedCollective: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: appData.collectiveRedirectBase)) ?? "\(appData.collectiveRedirectBase)"
    }

    var body: some View {
        ZStack {
            t.bg.ignoresSafeArea()

            if showingSuccess, let entry = savedEntry {
                successView(entry: entry)
            } else {
                timerView
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onDisappear {
            stopTimer()
            clearAllNotifications()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard isRunning else { return }
            switch newPhase {
            case .background:
                scheduleBackgroundNotifications()
            case .active:
                cancelBackgroundNotifications()
                if let start = startTime {
                    elapsedSeconds = Int(Date().timeIntervalSince(start))
                }
            default:
                break
            }
        }
    }

    // MARK: - Timer Screen

    private var timerView: some View {
        VStack(spacing: 0) {
            TopBar(leading: .back) { dismiss() }

            Spacer()

            VStack(spacing: 8) {
                Eyebrow(text: "YOUR NEW CHOICE", color: t.inkMute)

                Text(action)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(t.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if !isRunning && !hasShownReframe {
                Text("The discomfort at the start is just the chemical lag — it passes quickly.")
                    .font(.system(size: 13))
                    .foregroundStyle(t.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    .padding(.top, 12)
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(t.line, lineWidth: 3)
                    .frame(width: 260, height: 260)

                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(
                        markerComplete ? t.ok : t.accent,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 260, height: 260)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: ringProgress)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                t.accent.opacity(0.13),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 90
                        )
                    )
                    .frame(width: 180, height: 180)

                Text(timeString)
                    .font(.system(size: 44, weight: .thin, design: .monospaced))
                    .tracking(0.02 * 44)
                    .foregroundStyle(t.ink)
            }
            .frame(height: 280)

            if isRunning {
                if markerComplete {
                    Text("Done — keep going if you want.")
                        .font(.system(size: 13))
                        .foregroundStyle(t.inkSoft)
                        .padding(.top, 4)
                } else {
                    Text("Going...")
                        .font(.system(size: 13))
                        .foregroundStyle(t.inkSoft)
                        .padding(.top, 4)
                }

                if appData.currentEnergyLevel != .fine {
                    Text("Adjusted for your energy level")
                        .font(.system(size: 11))
                        .foregroundStyle(t.inkMute)
                        .padding(.top, 2)
                }
            }

            Spacer()

            VStack(spacing: 16) {
                if !isRunning {
                    Button {
                        hasShownReframe = true
                        startTimer()
                    } label: {
                        Label("Start", systemImage: "play.fill")
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(t.accent)
                            .foregroundStyle(t.accentInk)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 32)
                } else {
                    Text("Put the phone down. Do the thing.")
                        .font(.system(size: 13))
                        .italic()
                        .foregroundStyle(t.inkMute)

                    Button {
                        stopAndLog()
                    } label: {
                        Label("Stop & log", systemImage: "stop.fill")
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.clear)
                            .foregroundStyle(t.ink)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(t.line, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 32)
                }
            }

            Spacer()
                .frame(height: 60)
        }
    }

    // MARK: - Success Screen

    private func successView(entry: LogEntry) -> some View {
        let phrase = confirmationPhrase

        return VStack(spacing: 0) {
            Spacer()

            // Layer 1 — Behavior anchor
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(t.ok.opacity(0.4), lineWidth: 1)
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(t.ok)
                }

                TideHeadline(text: entry.newAction, color: t.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text(phrase)
                    .font(.system(size: 15))
                    .foregroundStyle(t.ok)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer().frame(height: 32)

            // Layer 2 — Change velocity
            VStack(spacing: 4) {
                let thisMonth = triggerRedirectsThisMonth()
                let lastMonth = triggerRedirectsLastMonth()
                if let lastMonth {
                    Text("This trigger: \(thisMonth) redirect\(thisMonth == 1 ? "" : "s") this month vs. \(lastMonth) last month")
                        .font(.system(size: 13))
                        .foregroundStyle(t.inkSoft)
                        .multilineTextAlignment(.center)
                } else {
                    Text("This trigger: \(thisMonth) redirect\(thisMonth == 1 ? "" : "s") this month")
                        .font(.system(size: 13))
                        .foregroundStyle(t.inkSoft)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)

            Spacer().frame(height: 12)

            // Layer 3 — Collective metric
            Text("\(formattedCollective) redirects logged this week")
                .font(.system(size: 11))
                .foregroundStyle(t.inkMute)

            Spacer().frame(height: 16)

            // "Didn't work" feedback
            if !didntWorkConfirmation {
                Button {
                    markDidntWork(action: entry.newAction)
                } label: {
                    Text("This one didn't work for me")
                        .font(.system(size: 11))
                        .foregroundStyle(t.inkMute)
                }
            } else {
                Text("Got it — you'll see it less.")
                    .font(.system(size: 11))
                    .foregroundStyle(t.inkMute)
                    .transition(.opacity)
            }

            Spacer()

            Button {
                recordPhraseIndex(phrase)
                dismiss()
            } label: {
                Text("Done")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(t.accent)
                    .foregroundStyle(t.accentInk)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)

            Spacer()
                .frame(height: 40)
        }
    }

    // MARK: - "Didn't work" feedback

    private func markDidntWork(action: String) {
        for wi in appData.wheels.indices {
            for oi in appData.wheels[wi].options.indices {
                if appData.wheels[wi].options[oi].label == action {
                    appData.wheels[wi].options[oi].skipCount += 1
                    appData.persistWheels()
                }
            }
        }
        withAnimation(.easeOut(duration: 0.3)) {
            didntWorkConfirmation = true
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation { didntWorkConfirmation = false }
        }
    }

    // MARK: - Timer Logic

    private func startTimer() {
        startTime = Date()
        elapsedSeconds = 0
        isRunning = true

        timerTask = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let start = startTime else { return }
            elapsedSeconds = Int(Date().timeIntervalSince(start))
        }
        RunLoop.main.add(timerTask!, forMode: .common)
    }

    private func stopTimer() {
        timerTask?.invalidate()
        timerTask = nil
        isRunning = false
    }

    private func stopAndLog() {
        stopTimer()
        clearAllNotifications()

        let minutes = Double(elapsedSeconds) / 60.0

        let entry = LogEntry(
            date: Date(),
            trigger: trigger,
            oldHabit: oldHabit,
            newAction: action,
            minutesSpent: minutes
        )

        appData.logEntries.append(entry)
        appData.collectiveRedirectBase += 1
        appData.persistLogEntries()
        savedEntry = entry

        withAnimation(.easeInOut(duration: 0.4)) {
            showingSuccess = true
        }
    }

    // MARK: - Background Notifications

    private static let bgIntervals: [TimeInterval] = [60, 300, 600, 900, 1200, 1500, 1800]
    private static let bgIDs: [String] = ["bg_timer_now"] + bgIntervals.map { "bg_timer_\(Int($0))" }

    private func scheduleBackgroundNotifications() {
        let center = UNUserNotificationCenter.current()
        let currentElapsed = startTime.map { Date().timeIntervalSince($0) } ?? 0

        let nowContent = UNMutableNotificationContent()
        nowContent.title = "Timer Running"
        nowContent.body = "\(action) — \(formatSeconds(Int(currentElapsed)))"
        nowContent.sound = nil
        center.add(UNNotificationRequest(
            identifier: "bg_timer_now",
            content: nowContent,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        ))

        for interval in Self.bgIntervals {
            let futureElapsed = Int(currentElapsed + interval)
            let content = UNMutableNotificationContent()
            content.title = "Timer Still Running"
            content.body = "\(action) — \(formatSeconds(futureElapsed))"
            content.sound = nil
            center.add(UNNotificationRequest(
                identifier: "bg_timer_\(Int(interval))",
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            ))
        }
    }

    private func cancelBackgroundNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: Self.bgIDs)
        center.removeDeliveredNotifications(withIdentifiers: Self.bgIDs)
    }

    private func clearAllNotifications() {
        let center = UNUserNotificationCenter.current()
        let allIDs = ["action_timer"] + Self.bgIDs
        center.removePendingNotificationRequests(withIdentifiers: allIDs)
        center.removeDeliveredNotifications(withIdentifiers: allIDs)
    }

    private func formatSeconds(_ total: Int) -> String {
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

// MARK: - Breathing Animation Modifier

private struct BreathingModifier: ViewModifier {
    let isActive: Bool
    let delay: Double

    @State private var animating = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive && animating ? 1.05 : 1.0)
            .opacity(isActive && animating ? 0.9 : 0.7)
            .animation(
                isActive
                ? Animation.easeInOut(duration: 6.0)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                : .default,
                value: animating
            )
            .onChange(of: isActive) { _, running in
                if running {
                    animating = true
                } else {
                    animating = false
                }
            }
    }
}

#Preview {
    NavigationStack {
        ActionTimerView(
            action: "Go for a walk",
            trigger: "Boredom",
            oldHabit: "Scrolling phone"
        )
        .environment(AppData.sample())
    }
}
