import SwiftUI

struct ContentView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    @State private var selectedTab = 0
    @State private var previousTab = 0
    @State private var showSOS = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TriggerListView()
            }
            .tabItem { Label("Spin", systemImage: "arrow.triangle.2.circlepath") }
            .tag(0)

            NavigationStack {
                SuccessLogView()
            }
            .tabItem { Label("Log", systemImage: "chart.bar") }
            .tag(1)

            Color.clear
                .tabItem { Label("SOS", systemImage: "bolt.circle.fill") }
                .tag(2)

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
            .tag(3)
        }
        .tint(t.accent)
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 2 {
                selectedTab = previousTab
                showSOS = true
            } else {
                previousTab = newValue
            }
        }
        .sheet(isPresented: $showSOS) {
            GreyStateView()
                .environment(appData)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppData.sample())
}
