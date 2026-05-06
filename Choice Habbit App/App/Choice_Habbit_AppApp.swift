import SwiftUI
import UserNotifications

@main
struct Choice_Habbit_AppApp: App {
    @State private var hasCompletedBreathing = false
    @State private var appData = AppData()
    @Environment(\.scenePhase) private var scenePhase

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
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase != .active {
                    appData.persistAll()
                }
            }
        }
    }
}
