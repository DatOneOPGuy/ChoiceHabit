import DeviceActivity
import ManagedSettings
import Foundation

/// Extension that monitors device activity and applies shields when time limits are exceeded.
/// NOTE: This file is scaffolding. It requires a separate Xcode extension target
/// (Device Activity Monitor Extension) to function. Create the target in Xcode,
/// then move this file into that target's source directory.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    let store = ManagedSettingsStore()

    override func intervalDidStart(for activity: DeviceActivity.Name) {
        super.intervalDidStart(for: activity)
        // Schedule window started — monitoring is active
    }

    override func intervalDidEnd(for activity: DeviceActivity.Name) {
        super.intervalDidEnd(for: activity)
        // Schedule window ended — clear all shields
        store.clearAllSettings()
    }

    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivity.Name
    ) {
        super.eventDidReachThreshold(event, activity: activity)
        // TIME LIMIT EXCEEDED — apply shield to monitored apps

        let config = ScreenTimeConfig.load()

        guard let rule = config.rules.first(
            where: { $0.id.uuidString == activity.rawValue }
        ) else { return }

        guard let data = rule.activitySelectionData,
              let selection = try? NSKeyedUnarchiver.unarchivedObject(
                  ofClass: FamilyActivitySelection.self,
                  from: data
              )
        else { return }

        // Apply shield to the selected apps
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(
            selection.categoryTokens
        )
        store.shield.webDomainCategories = .specific(
            selection.categoryTokens
        )
    }
}
