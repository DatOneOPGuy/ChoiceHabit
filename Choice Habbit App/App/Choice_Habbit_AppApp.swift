import SwiftUI
import UserNotifications

@main
struct Choice_Habbit_AppApp: App {
    @State private var hasCompletedBreathing = false
    @State private var appData = AppData()
    @AppStorage("themeChoice") private var themeChoice: String = ThemeChoice.auto.rawValue
    @Environment(\.scenePhase) private var scenePhase

    private var resolvedScheme: ColorScheme? {
        ThemeChoice(rawValue: themeChoice)?.colorScheme
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedBreathing {
                    ContentView()
                        .transition(.opacity)
                        .environment(appData)
                        .onAppear {
                            UNUserNotificationCenter.current().requestAuthorization(
                                options: [.alert, .sound, .badge]
                            ) { _, _ in }
                        }
                } else {
                    NavigationStack {
                        SpaceView(trigger: "") {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                hasCompletedBreathing = true
                            }
                        }
                    }
                }
            }
            .preferredColorScheme(resolvedScheme)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase != .active {
                    appData.persistAll()
                }
            }
        }
    }
}
