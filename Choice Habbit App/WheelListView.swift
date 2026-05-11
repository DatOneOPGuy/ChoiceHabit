//
//  WheelListView.swift
//  Choice Habbit App
//
//  Created by Joey Hansel on 26.04.26.
//

import SwiftUI

struct WheelListView: View {
    @Environment(AppData.self) private var appData

    var body: some View {
        List {
            ForEach(appData.wheels) { wheel in
                NavigationLink(destination: WheelEditView(wheelID: wheel.id)) {
                    VStack(alignment: .leading) {
                        Text(wheel.name)
                        Text("\(wheel.options.count) options")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteWheels)
        }
        .navigationTitle("Wheels")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let wheel = Wheel(name: "New Wheel", options: [])
                    appData.wheels.append(wheel)
                    appData.persistWheels()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }

    private func deleteWheels(at offsets: IndexSet) {
        let idsToDelete = offsets.map { appData.wheels[$0].id }
        for id in idsToDelete {
            appData.habitPairs.removeAll { $0.parentWheelID == id }
            for wi in appData.wheels.indices {
                for oi in appData.wheels[wi].options.indices {
                    if appData.wheels[wi].options[oi].childWheelID == id {
                        appData.wheels[wi].options[oi].childWheelID = nil
                    }
                }
            }
        }
        appData.wheels.remove(atOffsets: offsets)
        appData.persistAll()
    }
}

#Preview {
    NavigationStack {
        WheelListView()
    }
    .environment(AppData.sample())
}
