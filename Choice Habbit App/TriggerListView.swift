//
//  TriggerListView.swift
//  Choice Habbit App
//
//  Created by Joey Hansel on 25.04.26.
//

import SwiftUI

struct TriggerListView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header block
                VStack(alignment: .leading, spacing: 6) {
                    Eyebrow(text: "CHOICE HABIT", color: t.inkMute)

                    TideHeadline(
                        text: "What do you\nfeel right now?",
                        color: t.ink
                    )
                    .lineSpacing(-2)

                    Text("Pause. Notice the trigger. Choose a different path.")
                        .font(.system(size: 14))
                        .foregroundStyle(t.inkSoft)
                        .frame(maxWidth: 280, alignment: .leading)
                        .padding(.top, 2)
                }
                .padding(.horizontal, 18)
                .padding(.top, 24)
                .padding(.bottom, 20)

                // Trigger list
                if appData.habitPairs.isEmpty {
                    ContentUnavailableView(
                        "No Triggers Yet",
                        systemImage: "list.bullet",
                        description: Text("Go to Settings to add your first trigger.")
                    )
                    .foregroundStyle(t.inkSoft)
                } else {
                    VStack(spacing: 8) {
                        ForEach(Array(appData.habitPairs.enumerated()), id: \.element.id) { index, pair in
                            NavigationLink(destination: WheelSpinnerView(
                                wheelID: pair.parentWheelID,
                                trigger: pair.trigger,
                                oldHabit: pair.oldHabit
                            )) {
                                triggerRow(pair: pair, isFirst: index == 0)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .background(t.bg.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Trigger Row

    @ViewBuilder
    private func triggerRow(pair: HabitPair, isFirst: Bool) -> some View {
        HStack(spacing: 12) {
            // Circular badge with first letter
            ZStack {
                Circle()
                    .fill(t.surface)
                    .frame(width: 38, height: 38)

                Circle()
                    .stroke(t.line, lineWidth: 0.5)
                    .frame(width: 38, height: 38)

                Text(String(pair.trigger.prefix(1)).uppercased())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(t.accent)
            }

            // Label column
            VStack(alignment: .leading, spacing: 2) {
                Text(pair.trigger)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(t.ink)

                Text("instead of \(pair.oldHabit.lowercased())")
                    .font(.system(size: 12))
                    .foregroundStyle(t.inkMute)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(t.inkMute)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isFirst ? t.surfaceAlt : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isFirst ? t.line : Color.clear, lineWidth: 0.5)
                )
        )
    }
}

#Preview {
    NavigationStack {
        TriggerListView()
    }
    .environment(AppData.sample())
}
