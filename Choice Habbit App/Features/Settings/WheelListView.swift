import SwiftUI

struct WheelListView: View {
    @Environment(AppData.self) private var appData

    @State private var systemWheelsExpanded = false

    private var userWheels: [Wheel] { appData.wheels.filter { !$0.isGreyState } }
    private var systemWheels: [Wheel] { appData.wheels.filter { $0.isGreyState } }

    var body: some View {
        List {
            Section {
                ForEach(userWheels) { wheel in
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

            if !systemWheels.isEmpty {
                Section(isExpanded: $systemWheelsExpanded) {
                    ForEach(systemWheels) { wheel in
                        NavigationLink(destination: WheelEditView(wheelID: wheel.id)) {
                            VStack(alignment: .leading) {
                                Text(wheel.name)
                                Text("\(wheel.options.count) options")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Button {
                        withAnimation { systemWheelsExpanded.toggle() }
                    } label: {
                        HStack {
                            Text("System Wheels")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .rotationEffect(.degrees(systemWheelsExpanded ? 90 : 0))
                        }
                    }
                    .foregroundStyle(.secondary)
                }
            }
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
        let idsToDelete = offsets.map { userWheels[$0].id }
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
        appData.wheels.removeAll { idsToDelete.contains($0.id) }
        appData.persistAll()
    }
}

#Preview {
    NavigationStack {
        WheelListView()
    }
    .environment(AppData.sample())
}
