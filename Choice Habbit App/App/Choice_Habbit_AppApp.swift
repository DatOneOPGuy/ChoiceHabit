import SwiftUI
import UserNotifications

@main
struct Choice_Habbit_AppApp: App {
    @State private var appData = AppData()
    @AppStorage("themeChoice") private var themeChoice: String = ThemeChoice.auto.rawValue
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @Environment(\.scenePhase) private var scenePhase

    private var resolvedScheme: ColorScheme? {
        ThemeChoice(rawValue: themeChoice)?.colorScheme
    }

    private var showOnboarding: Bool {
        !onboardingCompleted
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environment(appData)

                if showOnboarding {
                    OnboardingView(appData: appData) {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            onboardingCompleted = true
                        }
                    }
                    .transition(.opacity)
                    .zIndex(2)
                }
            }
            .preferredColorScheme(resolvedScheme)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase != .active {
                    appData.persistAll()
                }
                if newPhase == .active && !appData.energyInferredThisSession {
                    appData.currentEnergyLevel = inferEnergyLevel()
                    appData.energyInferredThisSession = true
                }
            }
            .onAppear {
                migrateExistingUser()
                if onboardingCompleted {
                    UNUserNotificationCenter.current().requestAuthorization(
                        options: [.alert, .sound, .badge]
                    ) { _, _ in }
                }
                if !appData.energyInferredThisSession {
                    appData.currentEnergyLevel = inferEnergyLevel()
                    appData.energyInferredThisSession = true
                }
            }
        }
    }

    private func migrateExistingUser() {
        if !onboardingCompleted && !appData.wheels.isEmpty {
            onboardingCompleted = true
        }
    }

    private func inferEnergyLevel() -> EnergyLevel {
        let hour = Calendar.current.component(.hour, from: Date())

        if hour >= 0 && hour < 4 { return .empty }

        let sessionsToday = appData.logEntries.filter {
            Calendar.current.isDateInToday($0.date)
        }.count
        if sessionsToday >= 3 { return .empty }

        let slipsToday = appData.slips.filter {
            Calendar.current.isDateInToday($0.date)
        }.count
        if slipsToday >= 2 { return .strained }

        if let lastLog = appData.logEntries.sorted(by: { $0.date > $1.date }).first {
            let daysSince = Calendar.current.dateComponents([.day], from: lastLog.date, to: Date()).day ?? 0
            if daysSince >= 7 { return .strained }
        }

        return .fine
    }
}
