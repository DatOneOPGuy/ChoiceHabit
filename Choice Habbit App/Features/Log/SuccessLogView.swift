//
//  SuccessLogView.swift
//  Choice Habbit App
//
//  Created by Joey Hansel on 26.04.26.
//

import SwiftUI
import Charts

struct SuccessLogView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    @State private var selectedChartPage = 0

    private var totalMinutes: Double {
        appData.logEntries.reduce(0) { $0 + $1.minutesSpent }
    }

    private var minutesPerAction: [(action: String, minutes: Double)] {
        var dict: [String: Double] = [:]
        for entry in appData.logEntries {
            dict[entry.newAction, default: 0] += entry.minutesSpent
        }
        return dict.map { (action: $0.key, minutes: $0.value) }
            .sorted { $0.minutes > $1.minutes }
    }

    private var triggerFrequency: [(trigger: String, count: Int)] {
        var dict: [String: Int] = [:]
        for entry in appData.logEntries {
            dict[entry.trigger, default: 0] += 1
        }
        return dict.map { (trigger: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    private var badHabitList: String {
        appData.badHabits.map { $0.name }.joined(separator: ", ")
    }

    private var sparklineData: [Double] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<14).reversed().map { daysAgo -> Double in
            guard let day = cal.date(byAdding: .day, value: -daysAgo, to: today)
            else { return 0.0 }
            return appData.logEntries
                .filter { cal.startOfDay(for: $0.date) == day }
                .reduce(0) { $0 + $1.minutesSpent }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            TopBar(leading: .menu) {}

            if appData.logEntries.isEmpty {
                Spacer()
                ContentUnavailableView(
                    "No Sessions Yet",
                    systemImage: "checkmark.seal",
                    description: Text(
                        "Complete your first intervention to see progress."
                    )
                )
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        header
                        heroStatCard
                        topChoicesSection
                        chartSection
                        triggerFrequencySection
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .background(t.bg.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Eyebrow(text: "PRACTICE", color: t.inkMute)
            TideHeadline(text: "You've shown up.", color: t.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
        .padding(.horizontal, 24)
    }

    // MARK: - Hero Stat Card

    private var heroStatCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Big numeral
            Text(formattedMinutes(totalMinutes))
                .font(.system(size: 56, weight: .semibold, design: .rounded))
                .tracking(-0.04 * 56)
                .foregroundStyle(t.accent)

            // Sub-line
            subLine

            // Sparkline
            sparkline
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(t.surfaceAlt)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(t.line, lineWidth: 1)
                )
        )
        .padding(.top, 14)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var subLine: some View {
        let habits = badHabitList
        if habits.isEmpty {
            Text("Minutes spent on a different choice")
                .font(.system(size: 14))
                .foregroundStyle(t.inkSoft)
        } else {
            (Text("Minutes spent on a different choice \u{2014} instead of ")
                .font(.system(size: 14))
                .foregroundStyle(t.inkSoft)
            + Text(habits)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(t.warm))
        }
    }

    private var sparkline: some View {
        let data = sparklineData
        let maxVal = data.max() ?? 1
        let scale = maxVal > 0 ? maxVal : 1

        return VStack(spacing: 4) {
            GeometryReader { geo in
                let barCount = CGFloat(data.count)
                let gap: CGFloat = 4
                let totalGaps = gap * (barCount - 1)
                let barWidth = (geo.size.width - totalGaps) / barCount

                HStack(alignment: .bottom, spacing: gap) {
                    ForEach(Array(data.enumerated()), id: \.offset) { idx, val in
                        let height = max(2, (val / scale) * 36)
                        let isToday = idx == data.count - 1
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                isToday
                                    ? t.accent
                                    : t.accentSoft.opacity(0.55)
                            )
                            .frame(
                                width: barWidth,
                                height: CGFloat(height)
                            )
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .frame(height: 36)

            HStack {
                Text("2 WEEKS AGO")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .foregroundStyle(t.inkMute)
                Spacer()
                Text("TODAY")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .foregroundStyle(t.inkMute)
            }
        }
    }

    // MARK: - Top Choices

    private var topChoicesSection: some View {
        let top5 = Array(minutesPerAction.prefix(5))
        let maxMins = top5.first?.minutes ?? 1

        return VStack(alignment: .leading, spacing: 10) {
            Eyebrow(text: "TOP CHOICES", color: t.inkMute)

            if top5.isEmpty {
                Text("No actions logged yet.")
                    .font(.system(size: 14))
                    .foregroundStyle(t.inkMute)
            } else {
                ForEach(Array(top5.enumerated()), id: \.offset) { idx, item in
                    VStack(spacing: 6) {
                        HStack {
                            Text(item.action)
                                .font(.system(size: 14))
                                .foregroundStyle(t.ink)
                            Spacer()
                            Text(formattedMinutes(item.minutes))
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundStyle(t.inkSoft)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(t.line)
                                    .frame(height: 4)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(t.slices[idx % t.slices.count])
                                    .frame(
                                        width: geo.size.width
                                            * (item.minutes / maxMins),
                                        height: 4
                                    )
                            }
                        }
                        .frame(height: 4)
                    }
                }
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 24)
    }

    // MARK: - Charts (swipeable radar / bar)

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Eyebrow(text: "MINUTES PER ACTION", color: t.inkMute)

            TabView(selection: $selectedChartPage) {
                RadarChartView(data: minutesPerAction)
                    .tag(0)
                BarChartView(data: minutesPerAction)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 300)

            HStack(spacing: 16) {
                Text("Radar")
                    .font(.caption)
                    .foregroundStyle(selectedChartPage == 0 ? t.accent : t.inkMute)
                Text("Bar")
                    .font(.caption)
                    .foregroundStyle(selectedChartPage == 1 ? t.accent : t.inkMute)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(t.surfaceAlt)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(t.line, lineWidth: 1)
                )
        )
        .padding(.top, 16)
        .padding(.horizontal, 16)
    }

    // MARK: - Trigger Frequency

    private var triggerFrequencySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Eyebrow(text: "TRIGGER FREQUENCY", color: t.inkMute)

            Text("How often each trigger has fired")
                .font(.system(size: 12))
                .foregroundStyle(t.inkMute)

            Chart(triggerFrequency, id: \.trigger) { item in
                BarMark(
                    x: .value("Count", item.count),
                    y: .value("Trigger", item.trigger)
                )
                .foregroundStyle(t.accent.gradient)
                .cornerRadius(6)
                .annotation(position: .trailing) {
                    Text("\(item.count)")
                        .font(.caption2)
                        .foregroundStyle(t.inkMute)
                }
            }
            .frame(height: CGFloat(triggerFrequency.count) * 44)
            .chartXAxis(.hidden)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(t.surfaceAlt)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(t.line, lineWidth: 1)
                )
        )
        .padding(.top, 12)
        .padding(.horizontal, 16)
    }

}

#Preview {
    SuccessLogView()
        .environment(AppData.sample())
}
