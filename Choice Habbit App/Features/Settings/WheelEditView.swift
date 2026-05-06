//
//  WheelEditView.swift
//  Choice Habbit App
//
//  Created by Joey Hansel on 26.04.26.
//

import SwiftUI

struct WheelEditView: View {
    @Environment(AppData.self) private var appData
    let wheelID: UUID

    private var wheelIndex: Int? {
        appData.wheels.firstIndex { $0.id == wheelID }
    }

    var body: some View {
        @Bindable var appData = appData
        if let index = wheelIndex {
            Form {
                Section("Wheel Name") {
                    TextField("Name", text: $appData.wheels[index].name)
                }

                Section("Options") {
                    ForEach(appData.wheels[index].options) { option in
                        NavigationLink(destination: OptionEditView(wheelID: wheelID, optionID: option.id)) {
                            HStack {
                                Text(option.label)
                                Spacer()
                                Text("Weight: \(option.weight)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if option.childWheelID != nil {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .foregroundStyle(.teal)
                                }
                            }
                        }
                    }
                    .onDelete { offsets in
                        appData.wheels[index].options.remove(atOffsets: offsets)
                    }

                    Button {
                        let option = WheelOption(label: "New Option", weight: 5)
                        appData.wheels[index].options.append(option)
                    } label: {
                        Label("Add Option", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle(appData.wheels[index].name)
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear { appData.persistWheels() }
        }
    }
}

#Preview {
    let data = AppData.sample()
    NavigationStack {
        WheelEditView(wheelID: data.wheels.first!.id)
    }
    .environment(data)
}
