import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity

// Extend DeviceActivity name types for string-based init
extension DeviceActivityName {
    init(_ string: String) { self.init(rawValue: string) }
}

extension DeviceActivityEvent.Name {
    init(_ string: String) { self.init(rawValue: string) }
}

@Observable
class ScreenTimeManager {
    var config: ScreenTimeConfig

    private let store = ManagedSettingsStore()
    private let center = DeviceActivityCenter()

    init() {
        self.config = ScreenTimeConfig.load()
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            try await AuthorizationCenter.shared
                .requestAuthorization(for: .individual)
            config.isAuthorized = true
            config.save()
            return true
        } catch {
            print("Screen Time auth failed: \(error)")
            config.isAuthorized = false
            return false
        }
    }

    // MARK: - Monitoring

    func applyMonitoring() {
        center.stopMonitoring()

        guard config.isMonitoringEnabled, config.isAuthorized else { return }

        for rule in config.rules where rule.isEnabled {
            guard let selectionData = rule.activitySelectionData,
                  let selection = try? JSONDecoder().decode(
                      FamilyActivitySelection.self,
                      from: selectionData
                  )
            else { continue }

            let schedule = buildSchedule(for: rule)
            let eventName = DeviceActivityEvent.Name(rule.id.uuidString)
            let event = DeviceActivityEvent(
                applications: selection.applicationTokens,
                categories: selection.categoryTokens,
                webDomains: selection.webDomainTokens,
                threshold: DateComponents(minute: rule.timeLimitMinutes)
            )

            let activityName = DeviceActivityName(rule.id.uuidString)
            do {
                try center.startMonitoring(
                    activityName,
                    during: schedule,
                    events: [eventName: event]
                )
            } catch {
                print("Failed to monitor \(rule.name): \(error)")
            }
        }
    }

    func stopAllMonitoring() {
        center.stopMonitoring()
        store.clearAllSettings()
    }

    // MARK: - Rule Management

    func addRule(_ rule: AppLimitRule) {
        config.rules.append(rule)
        config.save()
        if config.isMonitoringEnabled { applyMonitoring() }
    }

    func updateRule(_ rule: AppLimitRule) {
        if let idx = config.rules.firstIndex(where: { $0.id == rule.id }) {
            config.rules[idx] = rule
            config.save()
            if config.isMonitoringEnabled { applyMonitoring() }
        }
    }

    func deleteRule(id: UUID) {
        config.rules.removeAll { $0.id == id }
        config.save()
        if config.isMonitoringEnabled { applyMonitoring() }
    }

    func toggleMonitoring(_ enabled: Bool) {
        config.isMonitoringEnabled = enabled
        config.save()
        if enabled {
            applyMonitoring()
        } else {
            stopAllMonitoring()
        }
    }

    func save() {
        config.save()
    }

    // MARK: - Schedule Builder

    private func buildSchedule(for rule: AppLimitRule) -> DeviceActivitySchedule {
        let startHour = rule.activeStartHour ?? 0
        let startMin = rule.activeStartMinute ?? 0
        let endHour = rule.activeEndHour ?? 23
        let endMin = rule.activeEndMinute ?? 59

        return DeviceActivitySchedule(
            intervalStart: DateComponents(hour: startHour, minute: startMin),
            intervalEnd: DateComponents(hour: endHour, minute: endMin),
            repeats: true
        )
    }
}
