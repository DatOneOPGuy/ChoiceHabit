import SwiftUI
import FamilyControls

struct AppLimitRuleView: View {
    @Bindable var manager: ScreenTimeManager
    let existingRule: AppLimitRule?

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    private var t: Tide { .resolve(colorScheme) }

    @State private var name: String = ""
    @State private var timeLimitMinutes: Int = 30
    @State private var activeDays: Set<Int> = Set(1...7)
    @State private var useActiveHours = false
    @State private var startTime = Calendar.current.date(
        from: DateComponents(hour: 9, minute: 0)
    ) ?? Date()
    @State private var endTime = Calendar.current.date(
        from: DateComponents(hour: 22, minute: 0)
    ) ?? Date()
    @State private var isEnabled = true
    @State private var activitySelection = FamilyActivitySelection()
    @State private var showingAppPicker = false

    private let presetLimits = [15, 30, 60, 120]
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
    // Calendar weekdays: 1=Sun, 2=Mon, ..., 7=Sat

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Eyebrow(
                            text: existingRule == nil ? "NEW RULE" : "EDIT RULE",
                            color: t.inkMute
                        )
                        TideHeadline(text: "Set your limit.", color: t.ink)
                    }
                    .padding(.top, 20)

                    // Rule name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rule name")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(t.inkMute)
                        TextField("e.g. Social media weekdays", text: $name)
                            .font(.system(size: 16))
                            .foregroundStyle(t.ink)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(t.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(t.line, lineWidth: 1)
                                    )
                            )
                    }

                    // App selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Apps to monitor")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(t.inkMute)

                        Button { showingAppPicker = true } label: {
                            HStack {
                                Image(systemName: "apps.iphone")
                                    .font(.system(size: 16))
                                    .foregroundStyle(t.accent)

                                let count = activitySelection.applicationTokens.count
                                    + activitySelection.categoryTokens.count
                                Text(count > 0
                                    ? "\(count) selected"
                                    : "Select apps & categories"
                                )
                                .font(.system(size: 15))
                                .foregroundStyle(count > 0 ? t.ink : t.inkMute)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13))
                                    .foregroundStyle(t.inkMute)
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(t.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(t.line, lineWidth: 1)
                                    )
                            )
                        }
                    }

                    // Time limit
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Time limit")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(t.inkMute)

                        HStack(spacing: 8) {
                            ForEach(presetLimits, id: \.self) { mins in
                                let selected = timeLimitMinutes == mins
                                Button { timeLimitMinutes = mins } label: {
                                    Text(mins < 60
                                        ? "\(mins)m"
                                        : "\(mins / 60)h"
                                    )
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(selected ? t.accent : t.ink)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selected
                                                ? t.accentSoft.opacity(0.15)
                                                : t.surface)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selected
                                                        ? t.accent : t.line,
                                                        lineWidth: selected ? 1.5 : 1
                                                    )
                                            )
                                    )
                                }
                            }
                        }

                        Stepper(
                            "\(timeLimitMinutes) minutes",
                            value: $timeLimitMinutes,
                            in: 5...480,
                            step: 5
                        )
                        .font(.system(size: 14))
                        .foregroundStyle(t.ink)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(t.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(t.line, lineWidth: 1)
                                )
                        )
                    }

                    // Active days
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Active days")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(t.inkMute)

                        HStack(spacing: 6) {
                            ForEach(1...7, id: \.self) { day in
                                let selected = activeDays.contains(day)
                                Button {
                                    if selected {
                                        activeDays.remove(day)
                                    } else {
                                        activeDays.insert(day)
                                    }
                                } label: {
                                    Text(dayLabels[day - 1])
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(
                                            selected ? t.accentInk : t.ink
                                        )
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(selected
                                                    ? t.accent
                                                    : t.surface)
                                                .overlay(
                                                    Circle().stroke(
                                                        selected
                                                            ? t.accent : t.line,
                                                        lineWidth: 1
                                                    )
                                                )
                                        )
                                }
                            }
                        }
                    }

                    // Active hours
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: $useActiveHours) {
                            Text("Active hours only")
                                .font(.system(size: 15))
                                .foregroundStyle(t.ink)
                        }
                        .tint(t.accent)

                        if useActiveHours {
                            HStack(spacing: 12) {
                                DatePicker(
                                    "Start",
                                    selection: $startTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()

                                Text("to")
                                    .foregroundStyle(t.inkMute)

                                DatePicker(
                                    "End",
                                    selection: $endTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(t.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(t.line, lineWidth: 1)
                                    )
                            )
                        }
                    }

                    // Enable toggle (edit mode only)
                    if existingRule != nil {
                        Toggle(isOn: $isEnabled) {
                            Text("Rule enabled")
                                .font(.system(size: 15))
                                .foregroundStyle(t.ink)
                        }
                        .tint(t.accent)
                    }

                    // Delete button (edit mode only)
                    if let existing = existingRule {
                        Button {
                            manager.deleteRule(id: existing.id)
                            dismiss()
                        } label: {
                            Text("Delete Rule")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(.red.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 120)
            }

            // Save button
            Button(action: saveRule) {
                Text(existingRule == nil ? "Add Rule" : "Save Changes")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        name.isEmpty || activeDays.isEmpty
                            ? t.line : t.accent
                    )
                    .foregroundStyle(
                        name.isEmpty || activeDays.isEmpty
                            ? t.inkMute : t.accentInk
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(name.isEmpty || activeDays.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .background(t.bg.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .familyActivityPicker(
            isPresented: $showingAppPicker,
            selection: $activitySelection
        )
        .onAppear { loadExisting() }
    }

    private func loadExisting() {
        guard let rule = existingRule else { return }
        name = rule.name
        timeLimitMinutes = rule.timeLimitMinutes
        activeDays = rule.activeDays
        isEnabled = rule.isEnabled

        if let sh = rule.activeStartHour {
            useActiveHours = true
            startTime = Calendar.current.date(
                from: DateComponents(
                    hour: sh, minute: rule.activeStartMinute ?? 0
                )
            ) ?? startTime
            endTime = Calendar.current.date(
                from: DateComponents(
                    hour: rule.activeEndHour ?? 23,
                    minute: rule.activeEndMinute ?? 59
                )
            ) ?? endTime
        }

        if let data = rule.activitySelectionData,
           let sel = try? JSONDecoder().decode(
               FamilyActivitySelection.self, from: data
           ) {
            activitySelection = sel
        }
    }

    private func saveRule() {
        let selectionData = try? JSONEncoder().encode(activitySelection)

        let startComps = Calendar.current.dateComponents(
            [.hour, .minute], from: startTime
        )
        let endComps = Calendar.current.dateComponents(
            [.hour, .minute], from: endTime
        )

        var rule = AppLimitRule(
            id: existingRule?.id ?? UUID(),
            name: name,
            activitySelectionData: selectionData,
            timeLimitMinutes: timeLimitMinutes,
            activeDays: activeDays,
            activeStartHour: useActiveHours ? startComps.hour : nil,
            activeStartMinute: useActiveHours ? startComps.minute : nil,
            activeEndHour: useActiveHours ? endComps.hour : nil,
            activeEndMinute: useActiveHours ? endComps.minute : nil,
            isEnabled: isEnabled
        )

        if existingRule != nil {
            manager.updateRule(rule)
        } else {
            manager.addRule(rule)
        }
        dismiss()
    }
}
