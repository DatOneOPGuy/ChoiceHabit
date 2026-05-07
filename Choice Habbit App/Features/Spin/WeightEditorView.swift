import SwiftUI

struct WeightEditorView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    private var t: Tide { .resolve(colorScheme) }

    let wheelID: UUID

    private var wheelIndex: Int? {
        appData.wheels.firstIndex { $0.id == wheelID }
    }

    var body: some View {
        @Bindable var appData = appData
        NavigationStack {
            if let index = wheelIndex {
                List {
                    ForEach(Array(appData.wheels[index].options.enumerated()), id: \.element.id) { optIndex, option in
                        HStack {
                            Circle()
                                .fill(t.slices[optIndex % t.slices.count])
                                .frame(width: 12, height: 12)

                            Text(option.label)
                                .frame(width: 80, alignment: .leading)

                            TappableSlider(
                                value: $appData.wheels[index].options[optIndex].weight,
                                range: 1...10
                            )

                            Text("\(option.weight)")
                                .monospacedDigit()
                                .frame(width: 24, alignment: .trailing)
                        }
                    }
                }
                .navigationTitle("Adjust Weights")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
            }
        }
    }
}
