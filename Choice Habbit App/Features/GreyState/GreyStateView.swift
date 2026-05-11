import SwiftUI

enum GreyStateLocation: String, CaseIterable {
    case bed    = "Bed"
    case couch  = "Couch"
    case screen = "Screen"

    var icon: String {
        switch self {
        case .bed:    return "bed.double.fill"
        case .couch:  return "sofa.fill"
        case .screen: return "desktopcomputer"
        }
    }

    var wheelName: String { "Grey State — \(rawValue)" }
}

struct GreyStateView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    @State private var selectedLocation: GreyStateLocation? = nil
    @State private var showSlipEntry = false

    var body: some View {
        if let location = selectedLocation {
            wheelScreen(for: location)
        } else {
            locationPicker
        }
    }

    // MARK: - Location Picker

    private var locationPicker: some View {
        ZStack(alignment: .topTrailing) {
            t.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Where are you?")
                    .font(.title2.bold())
                    .foregroundStyle(t.ink)
                    .padding(.top, 60)

                Spacer().frame(height: 32)

                VStack(spacing: 12) {
                    ForEach(GreyStateLocation.allCases, id: \.self) { location in
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                selectedLocation = location
                            }
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: location.icon)
                                    .font(.system(size: 26))
                                    .foregroundStyle(t.accent)
                                Text(location.rawValue)
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(t.ink)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, minHeight: 88)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(t.surfaceAlt)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(t.line, lineWidth: 0.5)
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                Button { showSlipEntry = true } label: {
                    Text("Already happened? Log it here.")
                        .font(.system(size: 13))
                        .foregroundStyle(t.inkSoft)
                }
                .padding(.bottom, 24)
            }
            .sheet(isPresented: $showSlipEntry) {
                SlipEntryView()
                    .environment(appData)
            }

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(t.inkMute)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(t.surfaceAlt))
            }
            .padding(20)
        }
    }

    // MARK: - Wheel Screen

    @ViewBuilder
    private func wheelScreen(for location: GreyStateLocation) -> some View {
        if let wheel = appData.wheels.first(where: { $0.isGreyState && $0.name == location.wheelName }) {
            NavigationStack {
                WheelSpinnerView(wheelID: wheel.id, greyStateMode: true)
                    .environment(appData)
            }
        } else {
            Text("Setup error — please restart the app")
                .foregroundStyle(t.inkMute)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(t.bg.ignoresSafeArea())
        }
    }
}
