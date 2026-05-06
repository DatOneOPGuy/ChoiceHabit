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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    totalMinutesHeader

                    if !appData.logEntries.isEmpty {
                        chartSection
                        triggerFrequencySection
                    }

                    logEntryList
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Success Log")
            .overlay {
                if appData.logEntries.isEmpty {
                    ContentUnavailableView(
                        "No Sessions Yet",
                        systemImage: "checkmark.seal",
                        description: Text("Complete your first intervention to see your progress here.")
                    )
                }
            }
        }
    }

    // MARK: - Total Minutes Header

    private var totalMinutesHeader: some View {
        VStack(spacing: 12) {
            Text("Total Productive Good Habit Minutes")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text(formattedMinutes(totalMinutes))
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(.teal)

            if !appData.badHabits.isEmpty {
                Text("Time saved by not: \(badHabitList)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Charts (swipeable, radar default)

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Minutes Per Action")
                .font(.headline)
                .padding(.horizontal)

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
                    .foregroundStyle(selectedChartPage == 0 ? .teal : .secondary)
                Text("Bar")
                    .font(.caption)
                    .foregroundStyle(selectedChartPage == 1 ? .teal : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)
    }

    // MARK: - Trigger Frequency

    private var triggerFrequencySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trigger Frequency")
                .font(.headline)
                .padding(.horizontal)

            Text("How often each trigger has fired")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Chart(triggerFrequency, id: \.trigger) { item in
                BarMark(
                    x: .value("Count", item.count),
                    y: .value("Trigger", item.trigger)
                )
                .foregroundStyle(Color.teal.gradient)
                .cornerRadius(6)
                .annotation(position: .trailing) {
                    Text("\(item.count)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: CGFloat(triggerFrequency.count) * 44)
            .padding(.horizontal)
            .chartXAxis(.hidden)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)
    }

    // MARK: - Log Entry List

    private var logEntryList: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !appData.logEntries.isEmpty {
                Text("Session History")
                    .font(.headline)
                    .padding(.horizontal)

                ForEach(appData.logEntries.reversed()) { entry in
                    LogEntryRow(entry: entry)
                }
            }
        }
    }

}

#Preview {
    SuccessLogView()
        .environment(AppData.sample())
}
