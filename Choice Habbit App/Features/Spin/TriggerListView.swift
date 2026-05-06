//
//  TriggerListView.swift
//  Choice Habbit App
//
//  Created by Joey Hansel on 25.04.26.
//

import SwiftUI

struct TriggerListView: View {
    @Environment(AppData.self) private var appData
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Feeling overwhelmed?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 30)

                if appData.habitPairs.isEmpty {
                    ContentUnavailableView(
                        "No Triggers Yet",
                        systemImage: "list.bullet",
                        description: Text("Go to Settings to add your first trigger.")
                    )
                } else {
                    List(appData.habitPairs) { pair in
                        NavigationLink(destination: WheelSpinnerView(
                            wheelID: pair.parentWheelID,
                            trigger: pair.trigger,
                            oldHabit: pair.oldHabit
                        )) {
                            Text(pair.trigger)
                                .font(.title3)
                                .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    TriggerListView()
        .environment(AppData.sample())
}
