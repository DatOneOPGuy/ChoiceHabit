//
//  LogEntryRow.swift
//  Choice Habbit App
//
//  Created by Joey Hansel on 26.04.26.
//

import SwiftUI

struct LogEntryRow: View {
    let entry: LogEntry

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }

    private var formattedDuration: String {
        if entry.minutesSpent < 1 {
            return "\(Int(entry.minutesSpent * 60))s"
        }
        return String(format: "%.1f min", entry.minutesSpent)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.newAction)
                        .font(.body)
                        .fontWeight(.semibold)

                    Text("instead of: \(entry.oldHabit)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(formattedDuration)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.teal)
            }

            Divider()

            HStack {
                Label(entry.trigger, systemImage: "bolt.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(formattedDate)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)
    }
}
