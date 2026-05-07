import Foundation

// MARK: - Option catalogs for WheelBuilder
// Each CatalogEntry has a label, default weight, and set of relevant triggers.

private typealias E = CatalogEntry

// MARK: - Base Secular Options (all users)

extension WheelBuilder {
    static let secularBase: [CatalogEntry] = [
        E(label: "Deep breathing", weight: 8,
          triggers: ["Stress", "Anxiety", "Anger"]),
        E(label: "5-4-3-2-1 grounding", weight: 8,
          triggers: ["Anxiety"]),
        E(label: "Mindfulness meditation", weight: 7,
          triggers: ["Stress", "Anxiety", "Anger"]),
        E(label: "Nature walk", weight: 7,
          triggers: ["Stress", "Anxiety", "Sadness", "Boredom"]),
        E(label: "Exercise", weight: 7,
          triggers: ["Boredom", "Anger", "Arousal", "Procrastination"]),
        E(label: "Set a 5-min timer", weight: 7,
          triggers: ["Procrastination"]),
        E(label: "Journaling", weight: 6,
          triggers: ["Stress", "Anxiety", "Sadness", "Loneliness"]),
        E(label: "Reading", weight: 6,
          triggers: ["Boredom", "Procrastination"]),
        E(label: "2-minute tidy up", weight: 6,
          triggers: ["Procrastination", "Boredom"]),
        E(label: "Count to 10", weight: 6,
          triggers: ["Anger"]),
        E(label: "Gratitude list", weight: 5,
          triggers: ["Sadness", "Anxiety"]),
        E(label: "Cold exposure", weight: 5,
          triggers: ["Arousal", "Anger", "Stress"]),
        E(label: "Progressive muscle relaxation", weight: 5,
          triggers: ["Stress", "Anxiety"]),
        E(label: "Squeeze ice cube", weight: 5,
          triggers: ["Anger", "Arousal"]),
        E(label: "Call a friend", weight: 4,
          triggers: ["Loneliness", "Sadness", "Boredom"]),
    ]
}

// MARK: - Spiritual (non-religious)

extension WheelBuilder {
    static let spiritualAdditions: [CatalogEntry] = [
        E(label: "Yoga flow", weight: 7,
          triggers: ["Stress", "Anger", "Anxiety", "Arousal"]),
        E(label: "Meditation with intention", weight: 7,
          triggers: ["Stress", "Anxiety", "Sadness"]),
        E(label: "Grounding in nature", weight: 7,
          triggers: ["Stress", "Anxiety", "Sadness"]),
        E(label: "Breathwork", weight: 6,
          triggers: ["Stress", "Anxiety", "Anger"]),
        E(label: "Visualization", weight: 6,
          triggers: ["Anxiety", "Procrastination", "Sadness"]),
        E(label: "Affirmations", weight: 5,
          triggers: ["Sadness", "Anxiety", "Loneliness"]),
        E(label: "Sound healing", weight: 4,
          triggers: ["Stress", "Anxiety"]),
        E(label: "Energy clearing", weight: 4,
          triggers: ["Stress", "Anger"]),
    ]
}

// MARK: - Christian

extension WheelBuilder {
    static let christianAdditions: [CatalogEntry] = [
        E(label: "Prayer", weight: 8,
          triggers: ["Stress", "Anxiety", "Anger", "Sadness", "Loneliness", "Arousal", "Boredom", "Procrastination"]),
        E(label: "Scripture reading", weight: 7,
          triggers: ["Anxiety", "Sadness", "Loneliness"]),
        E(label: "Philippians 4:6-7 meditation", weight: 7,
          triggers: ["Anxiety", "Stress"]),
        E(label: "Worship music", weight: 6,
          triggers: ["Sadness", "Stress", "Anxiety"]),
        E(label: "Devotional time", weight: 6,
          triggers: ["Boredom", "Loneliness"]),
        E(label: "Gratitude to God", weight: 6,
          triggers: ["Sadness", "Anger"]),
        E(label: "Service to others", weight: 5,
          triggers: ["Boredom", "Loneliness", "Sadness"]),
        E(label: "Church community connection", weight: 4,
          triggers: ["Loneliness", "Sadness"]),
    ]
}

// MARK: - Muslim

extension WheelBuilder {
    static let muslimAdditions: [CatalogEntry] = [
        E(label: "Salah (prayer)", weight: 8,
          triggers: ["Stress", "Anxiety", "Anger", "Sadness", "Loneliness", "Arousal", "Boredom", "Procrastination"]),
        E(label: "Dhikr (remembrance of Allah)", weight: 8,
          triggers: ["Anxiety", "Stress", "Anger"]),
        E(label: "Istighfar (seeking forgiveness)", weight: 7,
          triggers: ["Anger", "Arousal", "Sadness"]),
        E(label: "Quran recitation", weight: 7,
          triggers: ["Stress", "Sadness", "Anxiety"]),
        E(label: "Du'a (supplication)", weight: 7,
          triggers: ["Stress", "Anxiety", "Sadness", "Loneliness"]),
        E(label: "Wudu (ablution as reset)", weight: 6,
          triggers: ["Anger", "Arousal", "Stress"]),
        E(label: "Tafakkur (Islamic meditation)", weight: 6,
          triggers: ["Anxiety", "Stress", "Sadness"]),
        E(label: "Sadaqah (community service)", weight: 5,
          triggers: ["Boredom", "Loneliness"]),
    ]
}

// MARK: - Jewish

extension WheelBuilder {
    static let jewishAdditions: [CatalogEntry] = [
        E(label: "Tefillah (prayer)", weight: 8,
          triggers: ["Stress", "Anxiety", "Anger", "Sadness", "Loneliness", "Arousal", "Boredom", "Procrastination"]),
        E(label: "Psalms recitation", weight: 7,
          triggers: ["Anxiety", "Sadness", "Anger"]),
        E(label: "Torah study", weight: 7,
          triggers: ["Boredom", "Anxiety", "Stress"]),
        E(label: "Hitbodedut (personal prayer)", weight: 7,
          triggers: ["Anxiety", "Sadness", "Loneliness"]),
        E(label: "Brachot (blessings)", weight: 6,
          triggers: ["Stress", "Anxiety", "Sadness"]),
        E(label: "Shabbat rest practices", weight: 5,
          triggers: ["Stress", "Procrastination"]),
        E(label: "Tzedakah (charity)", weight: 5,
          triggers: ["Boredom", "Loneliness", "Sadness"]),
        E(label: "Tikkun (repair/improvement)", weight: 5,
          triggers: ["Procrastination", "Anger"]),
    ]
}

// MARK: - Hindu

extension WheelBuilder {
    static let hinduAdditions: [CatalogEntry] = [
        E(label: "Japa (mantra repetition)", weight: 8,
          triggers: ["Anxiety", "Stress", "Anger"]),
        E(label: "Pranayama (breath control)", weight: 7,
          triggers: ["Stress", "Anxiety", "Anger"]),
        E(label: "Dhyana (meditation)", weight: 7,
          triggers: ["Stress", "Anxiety", "Sadness"]),
        E(label: "Yoga asanas", weight: 7,
          triggers: ["Stress", "Anger", "Arousal", "Boredom"]),
        E(label: "Puja (worship)", weight: 6,
          triggers: ["Stress", "Anxiety", "Sadness", "Loneliness"]),
        E(label: "Reading Bhagavad Gita", weight: 6,
          triggers: ["Boredom", "Anxiety", "Sadness"]),
        E(label: "Seva (selfless service)", weight: 5,
          triggers: ["Boredom", "Loneliness", "Sadness"]),
        E(label: "Kirtan (devotional chanting)", weight: 5,
          triggers: ["Sadness", "Loneliness", "Stress"]),
    ]
}

// MARK: - Buddhist

extension WheelBuilder {
    static let buddhistAdditions: [CatalogEntry] = [
        E(label: "Vipassana meditation", weight: 8,
          triggers: ["Stress", "Anxiety", "Anger"]),
        E(label: "Loving-kindness (metta)", weight: 7,
          triggers: ["Anger", "Loneliness", "Sadness"]),
        E(label: "Mindful walking", weight: 7,
          triggers: ["Stress", "Anxiety", "Boredom"]),
        E(label: "Studying dharma", weight: 6,
          triggers: ["Boredom", "Anxiety"]),
        E(label: "Five precepts reflection", weight: 6,
          triggers: ["Arousal", "Anger"]),
        E(label: "Chanting", weight: 5,
          triggers: ["Stress", "Sadness"]),
        E(label: "Tonglen practice", weight: 5,
          triggers: ["Sadness", "Anger", "Loneliness"]),
        E(label: "Sangha connection", weight: 4,
          triggers: ["Loneliness", "Sadness"]),
    ]
}

// MARK: - Sikh

extension WheelBuilder {
    static let sikhAdditions: [CatalogEntry] = [
        E(label: "Naam japna (meditation on God's name)", weight: 8,
          triggers: ["Stress", "Anxiety", "Anger"]),
        E(label: "Ardas (prayer)", weight: 7,
          triggers: ["Stress", "Anxiety", "Sadness", "Loneliness", "Anger"]),
        E(label: "Simran (remembrance)", weight: 7,
          triggers: ["Anxiety", "Stress", "Sadness"]),
        E(label: "Reading Guru Granth Sahib", weight: 7,
          triggers: ["Boredom", "Anxiety", "Sadness"]),
        E(label: "Seva (community service)", weight: 6,
          triggers: ["Boredom", "Loneliness", "Sadness"]),
        E(label: "Kirtan (devotional singing)", weight: 6,
          triggers: ["Sadness", "Stress", "Loneliness"]),
        E(label: "Langar (communal meal service)", weight: 5,
          triggers: ["Loneliness", "Boredom"]),
    ]
}
