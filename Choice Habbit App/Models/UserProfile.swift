import SwiftUI

// MARK: - Worldview

enum Worldview: String, Codable, CaseIterable {
    case religious
    case spiritual
    case secular
    case preferNotToSay

    var displayName: String {
        switch self {
        case .religious: return "Religious"
        case .spiritual: return "Spiritual but not religious"
        case .secular: return "Secular / Atheist"
        case .preferNotToSay: return "Prefer not to say"
        }
    }

    var icon: String {
        switch self {
        case .religious: return "hands.and.sparkles"
        case .spiritual: return "leaf"
        case .secular: return "brain"
        case .preferNotToSay: return "hand.raised"
        }
    }
}

// MARK: - Faith Detail

enum FaithDetail: String, Codable, CaseIterable {
    case christian, muslim, jewish, hindu, buddhist, sikh, other

    var displayName: String {
        switch self {
        case .christian: return "Christian"
        case .muslim: return "Muslim"
        case .jewish: return "Jewish"
        case .hindu: return "Hindu"
        case .buddhist: return "Buddhist"
        case .sikh: return "Sikh"
        case .other: return "Other"
        }
    }
}

// MARK: - Onboarding Profile (transient during onboarding)

@Observable
class OnboardingProfile {
    var name = ""
    var selectedBadHabits: Set<String> = []
    var habitFunctions: [String: HabitFunction] = [:]
    var worldview: Worldview? = nil
    var faithDetail: FaithDetail? = nil
    var selectedTriggers: Set<String> = []
}

// MARK: - Constants

enum OnboardingConstants {
    static let badHabitOptions = [
        "Scrolling phone",
        "Smoking",
        "Overeating",
        "Procrastinating",
        "Anger issues",
        "Porn / lust",
        "Substance use",
        "Nail biting",
        "Gambling",
    ]

    static let triggerOptions = [
        "Boredom",
        "Stress",
        "Anxiety",
        "Anger",
        "Loneliness",
        "Arousal",
        "Procrastination",
        "Sadness",
    ]
}
