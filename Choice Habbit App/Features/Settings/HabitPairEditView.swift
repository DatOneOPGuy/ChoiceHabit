//
//  HabitPairEditView.swift
//  Choice Habbit App
//
//  Created by Joey Hansel on 26.04.26.
//

import SwiftUI

struct HabitPairEditView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.dismiss) private var dismiss
    let pairID: UUID

    private var pairIndex: Int? {
        appData.habitPairs.firstIndex { $0.id == pairID }
    }

    var body: some View {
        @Bindable var appData = appData
        if let index = pairIndex {
            Form {
                Section("Trigger") {
                    TextField("e.g. Boredom", text: $appData.habitPairs[index].trigger)
                }

                Section("Old Habit to Replace") {
                    TextField("e.g. Scrolling phone, Smoking", text: $appData.habitPairs[index].oldHabit)
                }

                Section("Parent Wheel") {
                    Text("Which wheel spins when this trigger is selected?")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(appData.wheels) { wheel in
                        Button {
                            appData.habitPairs[index].parentWheelID = wheel.id
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(wheel.name)
                                    Text("\(wheel.options.count) options")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if appData.habitPairs[index].parentWheelID == wheel.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.teal)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        appData.habitPairs.remove(at: index)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Trigger")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(appData.habitPairs[index].trigger)
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear { appData.persistHabitPairs() }
        }
    }
}

#Preview {
    let data = AppData.sample()
    NavigationStack {
        HabitPairEditView(pairID: data.habitPairs.first!.id)
    }
    .environment(data)
}
