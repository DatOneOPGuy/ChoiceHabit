//
//  BadHabitListView.swift
//  Choice Habbit App
//
//  Created by Joey Hansel on 26.04.26.
//

import SwiftUI

struct BadHabitListView: View {
    @Environment(AppData.self) private var appData
    @State private var newHabitName = ""

    var body: some View {
        @Bindable var appData = appData
        Form {
            Section("Your Bad Habits") {
                ForEach($appData.badHabits) { $habit in
                    TextField("Habit name", text: $habit.name)
                }
                .onDelete { indices in
                    appData.badHabits.remove(atOffsets: indices)
                    appData.persistBadHabits()
                }
            }

            Section("Add New") {
                HStack {
                    TextField("e.g. Smoking", text: $newHabitName)
                    Button("Add") {
                        guard !newHabitName.isEmpty else { return }
                        appData.badHabits.append(BadHabit(name: newHabitName))
                        newHabitName = ""
                        appData.persistBadHabits()
                    }
                    .disabled(newHabitName.isEmpty)
                }
            }
        }
        .navigationTitle("Bad Habits")
        .toolbar { EditButton() }
        .onDisappear { appData.persistBadHabits() }
    }
}

#Preview {
    NavigationStack {
        BadHabitListView()
    }
    .environment(AppData.sample())
}
