import SwiftUI
import UserNotifications

@main
struct Choice_Habbit_AppApp: App {
    @State private var hasCompletedBreathing = false
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

    private var showBreathing: Bool {
        onboardingCompleted && !hasCompletedBreathing
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environment(appData)

                if showBreathing {
                    NavigationStack {
                        SpaceView(trigger: "") {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                hasCompletedBreathing = true
                            }
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }

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
            }
            .onAppear {
                migrateExistingUser()
                if onboardingCompleted {
                    UNUserNotificationCenter.current().requestAuthorization(
                        options: [.alert, .sound, .badge]
                    ) { _, _ in }
                }
            }
        }
    }

    private func migrateExistingUser() {
        if !onboardingCompleted && !appData.wheels.isEmpty {
            onboardingCompleted = true
        }
    }
}
