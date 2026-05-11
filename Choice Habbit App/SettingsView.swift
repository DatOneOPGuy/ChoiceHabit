//
//  SettingsView.swift
//  Choice Habbit App
//
//  Created by Joey Hansel on 26.04.26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Wheels") {
                        WheelListView()
                    }
                }

                Section {
                    NavigationLink("Habit Pairs") {
                        HabitPairListView()
                    }
                }

                Section {
                    NavigationLink("Bad Habits") {
                        BadHabitListView()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppData.sample())
}
