//
//  SettingsView.swift
//  Choice Habbit App
//
//  Created by Joey Hansel on 26.04.26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    private var wheelCount: Int { appData.wheels.count }

    private var optionCount: Int {
        appData.wheels.reduce(0) { $0 + $1.options.count }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                groupedSections
            }
            .padding(.bottom, 40)
        }
        .background(t.bg.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Eyebrow(text: "SETTINGS", color: t.inkMute)
            TideHeadline(text: "Tend the practice.", color: t.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 18)
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    // MARK: - Grouped Sections

    private var groupedSections: some View {
        VStack(spacing: 0) {
            settingsGroup(title: "PRACTICE") {
                practiceRows
            }
            settingsGroup(title: "EXPERIENCE") {
                experienceRows
            }
            settingsGroup(title: "ABOUT") {
                aboutRows
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 16)
    }

    // MARK: - Practice Rows

    @ViewBuilder
    private var practiceRows: some View {
        let rows: [(icon: String, label: String, sub: String, index: Int)] = [
            ("bolt", "Triggers",
             "\(appData.habitPairs.count) active triggers", 0),
            ("circle.grid.cross", "Wheels",
             "\(wheelCount) wheels \u{00B7} \(optionCount) options", 1),
            ("xmark.circle", "Bad habits",
             "\(appData.badHabits.count) to replace", 2),
        ]

        ForEach(rows, id: \.index) { row in
            if row.index > 0 {
                Divider().overlay(t.line)
            }
            switch row.index {
            case 0:
                NavigationLink { HabitPairListView() } label: {
                    settingsRowContent(
                        icon: row.icon, label: row.label, sub: row.sub
                    )
                }
            case 1:
                NavigationLink { WheelListView() } label: {
                    settingsRowContent(
                        icon: row.icon, label: row.label, sub: row.sub
                    )
                }
            default:
                NavigationLink { BadHabitListView() } label: {
                    settingsRowContent(
                        icon: row.icon, label: row.label, sub: row.sub
                    )
                }
            }
        }
    }

    // MARK: - Experience Rows

    @ViewBuilder
    private var experienceRows: some View {
        let rows: [(icon: String, label: String, sub: String, index: Int)] = [
            ("circle.lefthalf.filled", "Theme", "System default", 0),
            ("bell", "Notifications", "Background timer alerts", 1),
            ("speaker.wave.2", "Sounds & haptics", "Soft tones", 2),
        ]

        ForEach(rows, id: \.index) { row in
            if row.index > 0 {
                Divider().overlay(t.line)
            }
            settingsRowContent(
                icon: row.icon, label: row.label, sub: row.sub
            )
        }
    }

    // MARK: - About Rows

    @ViewBuilder
    private var aboutRows: some View {
        let rows: [(icon: String, label: String, sub: String, index: Int)] = [
            ("info.circle", "Why Choice Habit", "Read the manifesto", 0),
            ("lock", "Privacy", "Everything stays on your phone", 1),
        ]

        ForEach(rows, id: \.index) { row in
            if row.index > 0 {
                Divider().overlay(t.line)
            }
            settingsRowContent(
                icon: row.icon, label: row.label, sub: row.sub
            )
        }
    }

    // MARK: - Settings Group Container

    private func settingsGroup<Content: View>(
        title: String,
        @ViewBuilder rows: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.5)
                .textCase(.uppercase)
                .foregroundStyle(t.inkMute)
                .padding(.top, 8)
                .padding(.bottom, 6)
                .padding(.horizontal, 10)

            VStack(spacing: 0) {
                rows()
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(t.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(t.line, lineWidth: 1)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.bottom, 10)
    }

    // MARK: - Row Content

    private func settingsRowContent(
        icon: String,
        label: String,
        sub: String
    ) -> some View {
        HStack(spacing: 12) {
            // Icon tile
            RoundedRectangle(cornerRadius: 10)
                .fill(t.surfaceAlt)
                .frame(width: 34, height: 34)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .imageScale(.medium)
                        .foregroundStyle(t.accent)
                )

            // Label + sub
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 15))
                    .foregroundStyle(t.ink)
                Text(sub)
                    .font(.system(size: 12))
                    .foregroundStyle(t.inkMute)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(t.inkMute)
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 14)
        .contentShape(Rectangle())
    }
}

#Preview {
    SettingsView()
        .environment(AppData.sample())
}
