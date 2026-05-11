import SwiftUI

struct SlipEntryView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    @State private var beat = 1
    @State private var selectedNote: String? = nil
    @State private var counteraction: String = ""

    private static let contextChips = ["Bored", "Stressed", "Tired", "Numb", "Lonely"]

    private static let counteractions = [
        "Drink a glass of water",
        "Stand up and stretch for 20 seconds",
        "Open a window or door",
        "Wash your hands with cold water",
        "Do 10 slow shoulder rolls",
        "Walk to the nearest window and look outside",
        "Put your phone down and sit upright for 30 seconds",
        "Take 3 slow breaths — in for 4, out for 6",
    ]

    var body: some View {
        ZStack {
            t.bg.ignoresSafeArea()

            switch beat {
            case 1: beat1
            case 2: beat2
            default: beat3
            }
        }
    }

    // MARK: - Beat 1: Acknowledge

    private var beat1: some View {
        VStack(spacing: 0) {
            dismissButton

            Spacer()

            VStack(spacing: 16) {
                TideHeadline(text: "It happened. That's okay.", color: t.ink)
                    .multilineTextAlignment(.center)

                Text("Logging this is more useful than ignoring it.")
                    .font(.system(size: 14))
                    .foregroundStyle(t.inkSoft)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.25)) { beat = 2 }
            } label: {
                Text("Continue \u{2192}")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(t.accent)
                    .foregroundStyle(t.accentInk)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Beat 2: Context

    private var beat2: some View {
        VStack(spacing: 0) {
            dismissButton

            Spacer()

            VStack(spacing: 20) {
                Text("What was going on?")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(t.ink)

                VStack(spacing: 10) {
                    ForEach(Self.contextChips, id: \.self) { chip in
                        Button {
                            selectedNote = chip
                        } label: {
                            Text(chip)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(selectedNote == chip ? t.accentInk : t.ink)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(selectedNote == chip ? t.accent : t.surfaceAlt)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(t.line, lineWidth: 0.5)
                                        )
                                )
                        }
                    }
                }
                .padding(.horizontal, 32)

                Button {
                    counteraction = Self.counteractions.randomElement() ?? Self.counteractions[0]
                    withAnimation(.easeInOut(duration: 0.25)) { beat = 3 }
                } label: {
                    Text("Skip \u{2192}")
                        .font(.system(size: 14))
                        .foregroundStyle(t.inkSoft)
                }
            }

            Spacer()

            if selectedNote != nil {
                Button {
                    counteraction = Self.counteractions.randomElement() ?? Self.counteractions[0]
                    withAnimation(.easeInOut(duration: 0.25)) { beat = 3 }
                } label: {
                    Text("Continue \u{2192}")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(t.accent)
                        .foregroundStyle(t.accentInk)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Beat 3: Micro-counteraction

    private var beat3: some View {
        VStack(spacing: 0) {
            dismissButton

            Spacer()

            VStack(spacing: 16) {
                Text(counteraction)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(t.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text("Do this one thing. Nothing else is required.")
                    .font(.system(size: 14))
                    .foregroundStyle(t.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    saveSlip(counteractionDone: true)
                } label: {
                    Text("Done")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(t.accent)
                        .foregroundStyle(t.accentInk)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Button {
                    saveSlip(counteractionDone: false)
                } label: {
                    Text("Skip")
                        .font(.system(size: 14))
                        .foregroundStyle(t.inkSoft)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Helpers

    private var dismissButton: some View {
        HStack {
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(t.inkMute)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(t.surfaceAlt))
            }
        }
        .padding(20)
    }

    private func saveSlip(counteractionDone: Bool) {
        let slip = SlipEntry(
            note: selectedNote ?? "",
            counteractionCompleted: counteractionDone
        )
        appData.slips.append(slip)
        appData.persistAll()
        dismiss()
    }
}
