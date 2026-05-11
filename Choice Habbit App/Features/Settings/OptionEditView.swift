import SwiftUI

struct OptionEditView: View {
    @Environment(AppData.self) private var appData
    let wheelID: UUID
    let optionID: UUID

    private var indices: (wheel: Int, option: Int)? {
        guard let wi = appData.wheels.firstIndex(where: { $0.id == wheelID }),
              let oi = appData.wheels[wi].options.firstIndex(where: { $0.id == optionID })
        else { return nil }
        return (wi, oi)
    }

    var body: some View {
        @Bindable var appData = appData
        if let idx = indices {
            Form {
                Section("Label") {
                    TextField("Label", text: $appData.wheels[idx.wheel].options[idx.option].label)
                }

                Section("Weight") {
                    HStack {
                        TappableSlider(
                            value: $appData.wheels[idx.wheel].options[idx.option].weight,
                            range: 1...10
                        )
                        Text("\(appData.wheels[idx.wheel].options[idx.option].weight)")
                            .monospacedDigit()
                            .frame(width: 24)
                    }
                    Text("Higher weight = selected more often")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Feedback") {
                    let skipCount = appData.wheels[idx.wheel].options[idx.option].skipCount
                    HStack {
                        Text("Skipped \(skipCount) time\(skipCount == 1 ? "" : "s")")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                        Spacer()
                        if skipCount > 0 {
                            Button("Reset") {
                                appData.wheels[idx.wheel].options[idx.option].skipCount = 0
                                appData.persistWheels()
                            }
                            .font(.system(size: 14))
                        }
                    }
                }

                Section("Child Wheel (optional)") {
                    Text("If set, landing on this option will spin another wheel instead of being a final result.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    let availableWheels = appData.wheels.filter { $0.id != wheelID }
                    let selectedID = appData.wheels[idx.wheel].options[idx.option].childWheelID

                    Button {
                        appData.wheels[idx.wheel].options[idx.option].childWheelID = nil
                    } label: {
                        HStack {
                            Text("None — this is a final action")
                            Spacer()
                            if selectedID == nil {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.teal)
                            }
                        }
                    }
                    .foregroundStyle(.primary)

                    ForEach(availableWheels) { wheel in
                        Button {
                            appData.wheels[idx.wheel].options[idx.option].childWheelID = wheel.id
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(wheel.name)
                                    Text("\(wheel.options.count) options")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if selectedID == wheel.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.teal)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle(appData.wheels[idx.wheel].options[idx.option].label)
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear { appData.persistWheels() }
        }
    }
}

#Preview {
    let data = AppData.sample()
    let wheel = data.wheels.first!
    NavigationStack {
        OptionEditView(wheelID: wheel.id, optionID: wheel.options.first!.id)
    }
    .environment(data)
}
