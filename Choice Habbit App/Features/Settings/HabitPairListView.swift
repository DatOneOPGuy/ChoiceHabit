//
//  HabitPairListView.swift
//  Choice Habbit App
//
//  Created by Joey Hansel on 26.04.26.
//

import SwiftUI

struct HabitPairListView: View {
    @Environment(AppData.self) private var appData

    var body: some View {
        List {
            ForEach(appData.habitPairs) { pair in
                NavigationLink(destination: HabitPairEditView(pairID: pair.id)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pair.trigger.isEmpty ? "Unnamed Trigger" : pair.trigger)
                            .fontWeight(.medium)
                        if let wheel = appData.wheel(for: pair.parentWheelID) {
                            Text("→ \(wheel.name)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("→ No wheel assigned")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .onDelete { offsets in
                appData.habitPairs.remove(atOffsets: offsets)
                appData.persistHabitPairs()
            }
        }
        .navigationTitle("Triggers")
        .overlay {
            if appData.wheels.isEmpty {
                ContentUnavailableView(
                    "No Wheels Yet",
                    systemImage: "arrow.triangle.2.circlepath",
                    description: Text("Go to Manage Wheels and create a wheel first.")
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    guard let firstWheel = appData.wheels.first else { return }
                    let pair = HabitPair(
                        trigger: "New Trigger",
                        oldHabit: "",
                        parentWheelID: firstWheel.id
                    )
                    appData.habitPairs.append(pair)
                    appData.persistHabitPairs()
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(appData.wheels.isEmpty)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HabitPairListView()
    }
    .environment(AppData.sample())
}
