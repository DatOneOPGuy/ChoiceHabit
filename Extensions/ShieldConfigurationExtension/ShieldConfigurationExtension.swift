import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Extension that provides the branded shield appearance when apps are blocked.
/// NOTE: This file is scaffolding. It requires a separate Xcode extension target
/// (Shield Configuration Extension) to function. Create the target in Xcode,
/// then move this file into that target's source directory.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    // Tide dark theme colors (hardcoded — extensions can't use SwiftUI Tide struct)
    private let tideBg = UIColor(red: 0.04, green: 0.09, blue: 0.10, alpha: 1.0)
    private let tideAccent = UIColor(red: 0.36, green: 0.78, blue: 0.74, alpha: 1.0)
    private let tideAccentDark = UIColor(red: 0.05, green: 0.43, blue: 0.43, alpha: 1.0)
    private let tideInkSoft = UIColor(red: 0.71, green: 0.77, blue: 0.77, alpha: 1.0)
    private let tideInkMute = UIColor(red: 0.48, green: 0.54, blue: 0.55, alpha: 1.0)

    override func configuration(
        shielding application: Application
    ) -> ShieldConfiguration {
        makeConfig()
    }

    override func configuration(
        shielding application: Application,
        in category: ActivityCategory
    ) -> ShieldConfiguration {
        makeConfig()
    }

    override func configuration(
        shielding webDomain: WebDomain
    ) -> ShieldConfiguration {
        makeConfig()
    }

    private func makeConfig() -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: tideBg,
            icon: UIImage(systemName: "arrow.triangle.2.circlepath"),
            title: ShieldConfiguration.Label(
                text: "Time to choose differently.",
                color: tideAccent
            ),
            subtitle: ShieldConfiguration.Label(
                text: "You've hit your limit on this app. Ready to do something better?",
                color: tideInkSoft
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Open Instead",
                color: .white
            ),
            primaryButtonBackgroundColor: tideAccentDark,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "5 More Minutes",
                color: tideInkMute
            )
        )
    }
}
