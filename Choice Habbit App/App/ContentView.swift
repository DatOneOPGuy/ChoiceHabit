import SwiftUI

struct ContentView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    var body: some View {
        TabView {
            NavigationStack {
                TriggerListView()
            }
            .tabItem { Label("Spin", systemImage: "arrow.triangle.2.circlepath") }

            NavigationStack {
                SuccessLogView()
            }
            .tabItem { Label("Log", systemImage: "chart.bar") }

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(t.accent)
    }
}

#Preview {
    ContentView()
        .environment(AppData.sample())
}
