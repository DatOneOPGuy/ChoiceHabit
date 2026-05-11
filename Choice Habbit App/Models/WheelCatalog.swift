import Foundation

// MARK: - Option catalogs for WheelBuilder
// Each CatalogEntry has a label, default weight, set of relevant triggers,
// and optional habit functions for weighting.

private typealias E = CatalogEntry
private typealias F = HabitFunction

// MARK: - Base Secular Options (all users)

extension WheelBuilder {
    static let secularBase: [CatalogEntry] = [
        E(label: "Deep breathing", weight: 8,
          triggers: ["Stress", "Anxiety", "Anger"],
          functions: [.anxiety]),
        E(label: "5-4-3-2-1 grounding", weight: 8,
          triggers: ["Anxiety"],
          functions: [.anxiety, .numbness]),
        E(label: "Mindfulness meditation", weight: 7,
          triggers: ["Stress", "Anxiety", "Anger"],
          functions: [.anxiety]),
        E(label: "Nature walk", weight: 7,
          triggers: ["Stress", "Anxiety", "Sadness", "Boredom"],
          functions: [.boredom, .numbness]),
        E(label: "Exercise", weight: 7,
          triggers: ["Boredom", "Anger", "Arousal", "Procrastination"],
          functions: [.restlessness, .boredom]),
        E(label: "Set a 5-min timer", weight: 7,
          triggers: ["Procrastination"],
          functions: [.boredom]),
        E(label: "Journaling", weight: 6,
          triggers: ["Stress", "Anxiety", "Sadness", "Loneliness"],
          functions: [.loneliness, .numbness]),
        E(label: "Reading", weight: 6,
          triggers: ["Boredom", "Procrastination"],
          functions: [.boredom]),
        E(label: "2-minute tidy up", weight: 6,
          triggers: ["Procrastination", "Boredom"],
          functions: [.boredom, .restlessness]),
        E(label: "Count to 10", weight: 6,
          triggers: ["Anger"],
          functions: [.restlessness]),
        E(label: "Gratitude list", weight: 5,
          triggers: ["Sadness", "Anxiety"],
          functions: [.numbness]),
        E(label: "Cold exposure", weight: 5,
          triggers: ["Arousal", "Anger", "Stress"],
          functions: [.restlessness]),
        E(label: "Progressive muscle relaxation", weight: 5,
          triggers: ["Stress", "Anxiety"],
          functions: [.anxiety]),
        E(label: "Squeeze ice cube", weight: 5,
          triggers: ["Anger", "Arousal"],
          functions: [.restlessness, .numbness]),
        E(label: "Call a friend", weight: 4,
          triggers: ["Loneliness", "Sadness", "Boredom"],
          functions: [.loneliness]),
    ]
}

// MARK: - Spiritual (non-religious)

extension WheelBuilder {
    static let spiritualAdditions: [CatalogEntry] = [
        E(label: "Yoga flow", weight: 7,
          triggers: ["Stress", "Anger", "Anxiety", "Arousal"],
          functions: [.restlessness, .anxiety]),
        E(label: "Meditation with intention", weight: 7,
          triggers: ["Stress", "Anxiety", "Sadness"],
          functions: [.anxiety, .numbness]),
        E(label: "Grounding in nature", weight: 7,
          triggers: ["Stress", "Anxiety", "Sadness"],
          functions: [.anxiety, .numbness]),
        E(label: "Breathwork", weight: 6,
          triggers: ["Stress", "Anxiety", "Anger"],
          functions: [.anxiety]),
        E(label: "Visualization", weight: 6,
          triggers: ["Anxiety", "Procrastination", "Sadness"],
          functions: [.anxiety, .numbness]),
        E(label: "Affirmations", weight: 5,
          triggers: ["Sadness", "Anxiety", "Loneliness"],
          functions: [.loneliness, .numbness]),
        E(label: "Sound healing", weight: 4,
          triggers: ["Stress", "Anxiety"],
          functions: [.anxiety]),
        E(label: "Energy clearing", weight: 4,
          triggers: ["Stress", "Anger"],
          functions: [.restlessness]),
    ]
}

// MARK: - Christian

extension WheelBuilder {
    static let christianAdditions: [CatalogEntry] = [
        E(label: "Prayer", weight: 8,
          triggers: ["Stress", "Anxiety", "Anger", "Sadness", "Loneliness", "Arousal", "Boredom", "Procrastination"]),
        E(label: "Scripture reading", weight: 7,
          triggers: ["Anxiety", "Sadness", "Loneliness"],
          functions: [.loneliness, .numbness]),
        E(label: "Philippians 4:6-7 meditation", weight: 7,
          triggers: ["Anxiety", "Stress"],
          functions: [.anxiety]),
        E(label: "Worship music", weight: 6,
          triggers: ["Sadness", "Stress", "Anxiety"],
          functions: [.numbness]),
        E(label: "Devotional time", weight: 6,
          triggers: ["Boredom", "Loneliness"],
          functions: [.boredom, .loneliness]),
        E(label: "Gratitude to God", weight: 6,
          triggers: ["Sadness", "Anger"],
          functions: [.numbness]),
        E(label: "Service to others", weight: 5,
          triggers: ["Boredom", "Loneliness", "Sadness"],
          functions: [.loneliness, .boredom]),
        E(label: "Church community connection", weight: 4,
          triggers: ["Loneliness", "Sadness"],
          functions: [.loneliness]),
    ]
}

// MARK: - Muslim

extension WheelBuilder {
    static let muslimAdditions: [CatalogEntry] = [
        E(label: "Salah (prayer)", weight: 8,
          triggers: ["Stress", "Anxiety", "Anger", "Sadness", "Loneliness", "Arousal", "Boredom", "Procrastination"]),
        E(label: "Dhikr (remembrance of Allah)", weight: 8,
          triggers: ["Anxiety", "Stress", "Anger"],
          functions: [.anxiety]),
        E(label: "Istighfar (seeking forgiveness)", weight: 7,
          triggers: ["Anger", "Arousal", "Sadness"],
          functions: [.numbness]),
        E(label: "Quran recitation", weight: 7,
          triggers: ["Stress", "Sadness", "Anxiety"],
          functions: [.anxiety, .numbness]),
        E(label: "Du'a (supplication)", weight: 7,
          triggers: ["Stress", "Anxiety", "Sadness", "Loneliness"],
          functions: [.loneliness, .anxiety]),
        E(label: "Wudu (ablution as reset)", weight: 6,
          triggers: ["Anger", "Arousal", "Stress"],
          functions: [.restlessness]),
        E(label: "Tafakkur (Islamic meditation)", weight: 6,
          triggers: ["Anxiety", "Stress", "Sadness"],
          functions: [.anxiety]),
        E(label: "Sadaqah (community service)", weight: 5,
          triggers: ["Boredom", "Loneliness"],
          functions: [.loneliness, .boredom]),
    ]
}

// MARK: - Jewish

extension WheelBuilder {
    static let jewishAdditions: [CatalogEntry] = [
        E(label: "Tefillah (prayer)", weight: 8,
          triggers: ["Stress", "Anxiety", "Anger", "Sadness", "Loneliness", "Arousal", "Boredom", "Procrastination"]),
        E(label: "Psalms recitation", weight: 7,
          triggers: ["Anxiety", "Sadness", "Anger"],
          functions: [.anxiety, .numbness]),
        E(label: "Torah study", weight: 7,
          triggers: ["Boredom", "Anxiety", "Stress"],
          functions: [.boredom]),
        E(label: "Hitbodedut (personal prayer)", weight: 7,
          triggers: ["Anxiety", "Sadness", "Loneliness"],
          functions: [.loneliness, .anxiety]),
        E(label: "Brachot (blessings)", weight: 6,
          triggers: ["Stress", "Anxiety", "Sadness"],
          functions: [.anxiety]),
        E(label: "Shabbat rest practices", weight: 5,
          triggers: ["Stress", "Procrastination"],
          functions: [.restlessness]),
        E(label: "Tzedakah (charity)", weight: 5,
          triggers: ["Boredom", "Loneliness", "Sadness"],
          functions: [.loneliness, .boredom]),
        E(label: "Tikkun (repair/improvement)", weight: 5,
          triggers: ["Procrastination", "Anger"],
          functions: [.restlessness]),
    ]
}

// MARK: - Hindu

extension WheelBuilder {
    static let hinduAdditions: [CatalogEntry] = [
        E(label: "Japa (mantra repetition)", weight: 8,
          triggers: ["Anxiety", "Stress", "Anger"],
          functions: [.anxiety]),
        E(label: "Pranayama (breath control)", weight: 7,
          triggers: ["Stress", "Anxiety", "Anger"],
          functions: [.anxiety, .restlessness]),
        E(label: "Dhyana (meditation)", weight: 7,
          triggers: ["Stress", "Anxiety", "Sadness"],
          functions: [.anxiety, .numbness]),
        E(label: "Yoga asanas", weight: 7,
          triggers: ["Stress", "Anger", "Arousal", "Boredom"],
          functions: [.restlessness, .boredom]),
        E(label: "Puja (worship)", weight: 6,
          triggers: ["Stress", "Anxiety", "Sadness", "Loneliness"],
          functions: [.loneliness]),
        E(label: "Reading Bhagavad Gita", weight: 6,
          triggers: ["Boredom", "Anxiety", "Sadness"],
          functions: [.boredom, .numbness]),
        E(label: "Seva (selfless service)", weight: 5,
          triggers: ["Boredom", "Loneliness", "Sadness"],
          functions: [.loneliness, .boredom]),
        E(label: "Kirtan (devotional chanting)", weight: 5,
          triggers: ["Sadness", "Loneliness", "Stress"],
          functions: [.loneliness, .numbness]),
    ]
}

// MARK: - Buddhist

extension WheelBuilder {
    static let buddhistAdditions: [CatalogEntry] = [
        E(label: "Vipassana meditation", weight: 8,
          triggers: ["Stress", "Anxiety", "Anger"],
          functions: [.anxiety]),
        E(label: "Loving-kindness (metta)", weight: 7,
          triggers: ["Anger", "Loneliness", "Sadness"],
          functions: [.loneliness, .numbness]),
        E(label: "Mindful walking", weight: 7,
          triggers: ["Stress", "Anxiety", "Boredom"],
          functions: [.boredom, .anxiety]),
        E(label: "Studying dharma", weight: 6,
          triggers: ["Boredom", "Anxiety"],
          functions: [.boredom]),
        E(label: "Five precepts reflection", weight: 6,
          triggers: ["Arousal", "Anger"],
          functions: [.restlessness]),
        E(label: "Chanting", weight: 5,
          triggers: ["Stress", "Sadness"],
          functions: [.numbness]),
        E(label: "Tonglen practice", weight: 5,
          triggers: ["Sadness", "Anger", "Loneliness"],
          functions: [.loneliness, .numbness]),
        E(label: "Sangha connection", weight: 4,
          triggers: ["Loneliness", "Sadness"],
          functions: [.loneliness]),
    ]
}

// MARK: - Sikh

extension WheelBuilder {
    static let sikhAdditions: [CatalogEntry] = [
        E(label: "Naam japna (meditation on God's name)", weight: 8,
          triggers: ["Stress", "Anxiety", "Anger"],
          functions: [.anxiety]),
        E(label: "Ardas (prayer)", weight: 7,
          triggers: ["Stress", "Anxiety", "Sadness", "Loneliness", "Anger"],
          functions: [.anxiety, .loneliness]),
        E(label: "Simran (remembrance)", weight: 7,
          triggers: ["Anxiety", "Stress", "Sadness"],
          functions: [.anxiety, .numbness]),
        E(label: "Reading Guru Granth Sahib", weight: 7,
          triggers: ["Boredom", "Anxiety", "Sadness"],
          functions: [.boredom, .numbness]),
        E(label: "Seva (community service)", weight: 6,
          triggers: ["Boredom", "Loneliness", "Sadness"],
          functions: [.loneliness, .boredom]),
        E(label: "Kirtan (devotional singing)", weight: 6,
          triggers: ["Sadness", "Stress", "Loneliness"],
          functions: [.loneliness, .numbness]),
        E(label: "Langar (communal meal service)", weight: 5,
          triggers: ["Loneliness", "Boredom"],
          functions: [.loneliness, .boredom]),
    ]
}
