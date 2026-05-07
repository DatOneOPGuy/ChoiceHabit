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

    private var timeString: String {
        let hours   = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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
        .navigationBarBackButtonHidden(isRunning)
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

            // Centered text block
            VStack(spacing: 8) {
                Eyebrow(text: "YOUR NEW CHOICE", color: t.inkMute)

                Text(action)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(t.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            // Breathing rings
            ZStack {
                // Outer ring - breathing
                Circle()
                    .stroke(t.line, lineWidth: 1)
                    .frame(width: 260, height: 260)
                    .opacity(isRunning ? 0.7 : 0.7)
                    .modifier(BreathingModifier(
                        isActive: isRunning,
                        delay: 0
                    ))

                // Middle ring - breathing with delay
                Circle()
                    .stroke(t.accentSoft, lineWidth: 1)
                    .frame(width: 220, height: 220)
                    .opacity(isRunning ? 0.6 : 0.6)
                    .modifier(BreathingModifier(
                        isActive: isRunning,
                        delay: 0.6
                    ))

                // Inner glow
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

                // Timer text
                Text(timeString)
                    .font(.system(size: 44, weight: .thin, design: .monospaced))
                    .tracking(0.02 * 44)
                    .foregroundStyle(t.ink)
            }
            .frame(height: 280)

            Spacer()

            // Sub-line and buttons
            VStack(spacing: 16) {
                if !isRunning {
                    Button {
                        startTimer()
                    } label: {
                        Label("Start Action Timer", systemImage: "play.fill")
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
        VStack(spacing: 32) {
            Spacer()

            // Checkmark with static halo ring
            ZStack {
                Circle()
                    .stroke(t.accentSoft.opacity(0.4), lineWidth: 1)
                    .frame(width: 140, height: 140)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(t.accent)
            }

            VStack(spacing: 12) {
                Text("Well done.")
                    .font(.largeTitle.bold())
                    .foregroundStyle(t.ink)

                Text("You spent \(formattedMinutes(entry.minutesSpent)) doing:")
                    .font(.subheadline)
                    .foregroundStyle(t.inkSoft)

                Text(entry.newAction)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(t.accent)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Stats card
            VStack(spacing: 8) {
                Text("Total Productive Good Habit Minutes")
                    .font(.caption)
                    .foregroundStyle(t.inkMute)
                    .multilineTextAlignment(.center)

                Text(formattedMinutes(totalMinutes))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(t.ink)

                Text("saved by not: \(entry.oldHabit)")
                    .font(.caption)
                    .foregroundStyle(t.inkMute)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(t.surfaceAlt)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(t.line, lineWidth: 1)
                    )
            )
            .padding(.horizontal, 32)

            Spacer()

            Button {
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

    // MARK: - Helpers

    private var totalMinutes: Double {
        appData.logEntries.reduce(0) { $0 + $1.minutesSpent }
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
