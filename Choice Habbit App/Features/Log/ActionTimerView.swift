import SwiftUI
import UserNotifications

struct ActionTimerView: View {
    let action: String
    let trigger: String
    let oldHabit: String

    @Environment(AppData.self) private var appData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

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
            Color(red: 0.07, green: 0.07, blue: 0.12)
                .ignoresSafeArea()

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
            Spacer()

            VStack(spacing: 12) {
                Text("Your new choice")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))

                Text(action)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.teal.opacity(0.15), lineWidth: 2)
                    .frame(width: 240, height: 240)

                Circle()
                    .stroke(
                        isRunning ? Color.teal.opacity(0.4) : Color.white.opacity(0.1),
                        lineWidth: 1.5
                    )
                    .frame(width: 200, height: 200)

                Text(timeString)
                    .font(.system(size: 52, weight: .thin, design: .monospaced))
                    .foregroundStyle(.white)
            }

            Spacer()

            VStack(spacing: 16) {
                if !isRunning {
                    Button {
                        startTimer()
                    } label: {
                        Label("Start Action Timer", systemImage: "play.fill")
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.teal)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 32)
                } else {
                    Button {
                        stopAndLog()
                    } label: {
                        Label("Stop & Log Success", systemImage: "stop.fill")
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.teal.opacity(0.6), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 32)

                    Text("Put your phone down and do the thing.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
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

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 72))
                .foregroundStyle(.teal)

            VStack(spacing: 12) {
                Text("Well done.")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text("You spent \(formattedMinutes(entry.minutesSpent)) doing:")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))

                Text(entry.newAction)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.teal)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 8) {
                Text("Total Productive Good Habit Minutes")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)

                Text(formattedMinutes(totalMinutes))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("saved by not: \(entry.oldHabit)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.07))
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
                    .background(Color.teal)
                    .foregroundStyle(.white)
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
