import SwiftUI

struct ContentView: View {
    @Environment(AppData.self) private var appData

    var body: some View {
        TabView {
            TriggerListView()
                .tabItem { Label("Spin", systemImage: "arrow.triangle.2.circlepath") }

            SuccessLogView()
                .tabItem { Label("Log", systemImage: "chart.bar") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppData.sample())
}
