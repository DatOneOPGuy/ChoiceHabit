import ManagedSettings
import ManagedSettingsUI

/// Extension that handles user interactions on the shield screen.
/// NOTE: This file is scaffolding. It requires a separate Xcode extension target
/// (Shield Action Extension) to function. Create the target in Xcode,
/// then move this file into that target's source directory.
class ShieldActionExtension: ShieldActionDelegate {
    let store = ManagedSettingsStore()

    override func handle(
        action: ShieldAction,
        for application: Application,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            // "Open Instead" — clear shield and close
            store.clearAllSettings()
            completionHandler(.close)

        case .secondaryButtonPressed:
            // "5 More Minutes" — temporarily defer the shield
            store.clearAllSettings()
            completionHandler(.defer)

        @unknown default:
            completionHandler(.close)
        }
    }

    override func handle(
        action: ShieldAction,
        for webDomain: WebDomain,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handle(action: action, for: Application(), completionHandler: completionHandler)
    }
}
