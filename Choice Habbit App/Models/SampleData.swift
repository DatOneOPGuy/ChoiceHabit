import Foundation

enum SampleData {
    static func populate(_ appData: AppData) {
        let exerciseWheel = Wheel(name: "Exercise Options", options: [
            WheelOption(label: "Push-ups", weight: 5),
            WheelOption(label: "Walk", weight: 8),
            WheelOption(label: "Stretch", weight: 3),
        ])
        let mindWheel = Wheel(name: "Mind Options", options: [
            WheelOption(label: "Read", weight: 7),
            WheelOption(label: "Journal", weight: 4),
            WheelOption(label: "Meditate", weight: 6),
        ])
        let boredomWheel = Wheel(name: "Boredom", options: [
            WheelOption(label: "Physical", weight: 7, childWheelID: exerciseWheel.id),
            WheelOption(label: "Mental", weight: 6, childWheelID: mindWheel.id),
            WheelOption(label: "Creative", weight: 4),
        ])

        let stressWheel = Wheel(name: "Stress Relief", options: [
            WheelOption(label: "Deep breathing", weight: 7),
            WheelOption(label: "Walk outside", weight: 8),
            WheelOption(label: "Listen to music", weight: 5),
            WheelOption(label: "Stretch", weight: 4),
            WheelOption(label: "Call a friend", weight: 3),
        ])

        let procrastinationWheel = Wheel(name: "Quick Starts", options: [
            WheelOption(label: "2-min tidy up", weight: 6),
            WheelOption(label: "Write one sentence", weight: 7),
            WheelOption(label: "Set a 5-min timer", weight: 8),
            WheelOption(label: "Make a to-do list", weight: 5),
        ])

        let anxietyWheel = Wheel(name: "Grounding", options: [
            WheelOption(label: "5-4-3-2-1 senses", weight: 8),
            WheelOption(label: "Cold water on face", weight: 5),
            WheelOption(label: "Box breathing", weight: 7),
            WheelOption(label: "Name 3 things you see", weight: 6),
        ])

        let angerWheel = Wheel(name: "Cool Down", options: [
            WheelOption(label: "Count to 10", weight: 6),
            WheelOption(label: "Squeeze ice cube", weight: 5),
            WheelOption(label: "Go for a run", weight: 7),
            WheelOption(label: "Write it out", weight: 4),
            WheelOption(label: "Progressive muscle relax", weight: 5),
        ])

        let arousalWheel = Wheel(name: "Redirect Energy", options: [
            WheelOption(label: "Cold shower", weight: 6),
            WheelOption(label: "Intense workout", weight: 8),
            WheelOption(label: "Go for a walk", weight: 7),
            WheelOption(label: "Clean the house", weight: 5),
            WheelOption(label: "Call someone", weight: 4),
        ])

        appData.wheels = [
            exerciseWheel, mindWheel,
            boredomWheel, stressWheel, procrastinationWheel,
            anxietyWheel, angerWheel, arousalWheel,
        ]

        appData.habitPairs = [
            HabitPair(trigger: "Boredom", oldHabit: "Scrolling phone", parentWheelID: boredomWheel.id),
            HabitPair(trigger: "Stress", oldHabit: "Stress eating", parentWheelID: stressWheel.id),
            HabitPair(trigger: "Procrastination", oldHabit: "Putting things off", parentWheelID: procrastinationWheel.id),
            HabitPair(trigger: "Anxiety", oldHabit: "Overthinking", parentWheelID: anxietyWheel.id),
            HabitPair(trigger: "Anger", oldHabit: "Lashing out", parentWheelID: angerWheel.id),
            HabitPair(trigger: "Arousal", oldHabit: "Impulsive behavior", parentWheelID: arousalWheel.id),
        ]

        appData.badHabits = [
            BadHabit(name: "Scrolling phone"),
            BadHabit(name: "Smoking"),
            BadHabit(name: "Playing video games"),
        ]
    }
}
