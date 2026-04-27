//
//  ContentView.swift
//  Choice Habbit App
//
//  Created by Joey Hansel on 25.04.26.
//

import SwiftUI

// MARK: - Content View (Tab Bar)

struct ContentView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    var body: some View {
        TabView {
            NavigationStack {
                TriggerListView()
            }
            .tabItem { Label("Spin", systemImage: "arrow.triangle.2.circlepath") }

            NavigationStack {
                SuccessLogView()
            }
            .tabItem { Label("Log", systemImage: "chart.bar") }

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(t.accent)
    }
}

// MARK: - Wheel Spinner View

struct WheelSpinnerView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    private var t: Tide { .resolve(colorScheme) }

    let wheelID: UUID
    var trigger: String = ""
    var oldHabit: String = ""

    @State private var currentWheelID: UUID
    @State private var rotation = 0.0
    @State private var isSpinning = false
    @State private var animateRotation = false
    @State private var result: String?
    @State private var isFinalResult = false
    @State private var showingEditor = false
    @State private var navigateToTimer = false
    @State private var finalAction = ""

    init(wheelID: UUID, trigger: String = "", oldHabit: String = "") {
        self.wheelID = wheelID
        self.trigger = trigger
        self.oldHabit = oldHabit
        self._currentWheelID = State(initialValue: wheelID)
    }

    private var currentWheel: Wheel? {
        appData.wheel(for: currentWheelID)
    }

    private var currentOptions: [WheelOption] {
        currentWheel?.options ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            topBar

            // Header area
            headerSection

            Spacer(minLength: 12)

            // Wheel
            wheelSection

            // Hint
            if result == nil {
                Text("Tap the wheel to spin")
                    .font(.system(size: 13))
                    .foregroundStyle(t.inkMute)
                    .padding(.top, 8)
            }

            // Result
            if let result {
                Text(result)
                    .font(.title2.bold())
                    .foregroundStyle(t.accent)
                    .transition(.scale.combined(with: .opacity))
                    .padding(.top, 12)
            }

            Spacer()

            // Footer card
            footerCard
        }
        .background(t.bg.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingEditor, onDismiss: {
            appData.persistWheels()
        }) {
            WeightEditorView(wheelID: currentWheelID)
        }
        .navigationDestination(isPresented: $navigateToTimer) {
            ActionTimerView(
                action: finalAction,
                trigger: trigger,
                oldHabit: oldHabit
            )
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(t.ink)
            }

            Spacer()

            Button { showingEditor = true } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(t.ink)
            }
            .disabled(isSpinning)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !trigger.isEmpty {
                Eyebrow(
                    text: "\(trigger) \u{00B7} INSTEAD OF \(oldHabit)",
                    color: t.inkMute
                )
            }

            TideHeadline(
                text: currentWheel?.name ?? "Spin the Wheel!",
                color: t.ink
            )
            .animation(.easeInOut, value: currentWheelID)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    // MARK: - Wheel

    private var wheelSection: some View {
        ZStack(alignment: .top) {
            // Halo
            Circle()
                .fill(t.surfaceAlt.opacity(0.5))
                .frame(width: 280, height: 280)

            // Wheel
            SpinWheelView(options: currentOptions)
                .frame(width: 260, height: 260)
                .rotationEffect(.radians(rotation))
                .animation(
                    animateRotation
                        ? .timingCurve(0.12, 0.7, 0.2, 1.0, duration: 4.0)
                        : nil,
                    value: rotation
                )
                .shadow(
                    color: colorScheme == .dark
                        ? Color(red: 0, green: 0, blue: 0, opacity: 0.4)
                        : Color(red: 15/255, green: 42/255, blue: 46/255, opacity: 0.12),
                    radius: 12, x: 0, y: 4
                )

            // Pointer
            Image(systemName: "arrowtriangle.down.fill")
                .font(.title2)
                .foregroundStyle(t.ink)
                .offset(y: -5)
        }
        .frame(width: 280, height: 290)
        .onTapGesture {
            spin()
        }
    }

    // MARK: - Footer Card

    private var footerCard: some View {
        HStack(spacing: 14) {
            // Accent circle with checkmark
            ZStack {
                Circle()
                    .fill(t.accent)
                    .frame(width: 32, height: 32)
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Eyebrow(
                    text: "\(currentOptions.count) PATHS \u{00B7} WEIGHTED BY WHAT WORKS",
                    color: t.inkMute
                )
                Text("Let the wheel decide for you.")
                    .font(.system(size: 14))
                    .foregroundStyle(t.inkSoft)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(t.surfaceAlt)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(t.line, lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    // MARK: - Spin Logic

    private func spin() {
        guard !isSpinning else { return }
        let options = currentOptions
        guard !options.isEmpty else { return }
        isSpinning = true
        result = nil
        isFinalResult = false

        let totalWeight = options.reduce(0.0) { $0 + Double($1.weight) }
        guard totalWeight > 0 else { return }

        // Weighted random selection
        let random = Double.random(in: 0..<totalWeight)
        var cumulative = 0.0
        var selectedIndex = 0
        for (index, option) in options.enumerated() {
            cumulative += Double(option.weight)
            if random < cumulative {
                selectedIndex = index
                break
            }
        }

        // Midpoint angle of the selected slice
        var midAngle = 0.0
        for i in 0..<selectedIndex {
            midAngle += (Double(options[i].weight) / totalWeight) * 2 * .pi
        }
        midAngle += (Double(options[selectedIndex].weight) / totalWeight) * .pi

        let sliceAngle = (Double(options[selectedIndex].weight) / totalWeight) * 2 * .pi
        let jitter = Double.random(in: -sliceAngle * 0.3...sliceAngle * 0.3)
        midAngle += jitter

        let targetModulo = 2 * Double.pi - midAngle
        let currentModulo = rotation.truncatingRemainder(dividingBy: 2 * .pi)
        var delta = targetModulo - currentModulo
        if delta < 0 { delta += 2 * .pi }

        let fullRotations = Double(Int.random(in: 5...8)) * 2 * .pi

        animateRotation = true
        rotation += fullRotations + delta

        let selectedOption = options[selectedIndex]

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(4.0))

            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                result = selectedOption.label
            }

            if let childID = selectedOption.childWheelID,
               appData.wheel(for: childID) != nil {
                // Chain: show result briefly, then load child wheel
                try? await Task.sleep(for: .seconds(1.5))

                animateRotation = false
                currentWheelID = childID
                rotation = 0
                result = nil
                isSpinning = false

                // Auto-spin the child wheel after a brief pause
                try? await Task.sleep(for: .seconds(0.6))
                spin()
            } else {
                withAnimation {
                    isFinalResult = true
                }
                isSpinning = false

                // Navigate to action timer after showing final result
                try? await Task.sleep(for: .seconds(1.5))
                finalAction = selectedOption.label
                navigateToTimer = true
            }
        }
    }
}

// MARK: - Weight Editor

struct WeightEditorView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    private var t: Tide { .resolve(colorScheme) }

    let wheelID: UUID

    private var wheelIndex: Int? {
        appData.wheels.firstIndex { $0.id == wheelID }
    }

    var body: some View {
        @Bindable var appData = appData
        NavigationStack {
            if let index = wheelIndex {
                List {
                    ForEach(Array(appData.wheels[index].options.enumerated()), id: \.element.id) { optIndex, option in
                        HStack {
                            Circle()
                                .fill(t.slices[optIndex % t.slices.count])
                                .frame(width: 12, height: 12)

                            Text(option.label)
                                .frame(width: 80, alignment: .leading)

                            TappableSlider(
                                value: $appData.wheels[index].options[optIndex].weight,
                                range: 1...10
                            )

                            Text("\(option.weight)")
                                .monospacedDigit()
                                .frame(width: 24, alignment: .trailing)
                        }
                    }
                }
                .navigationTitle("Adjust Weights")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
            }
        }
    }
}

// MARK: - Tappable Slider

struct TappableSlider: View {
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        GeometryReader { geo in
            let steps = CGFloat(range.upperBound - range.lowerBound)
            let fraction = CGFloat(value - range.lowerBound) / steps
            let thumbX = fraction * geo.size.width

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray4))
                    .frame(height: 6)

                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: thumbX, height: 6)

                Circle()
                    .fill(.white)
                    .shadow(radius: 2)
                    .frame(width: 24, height: 24)
                    .offset(x: thumbX - 12)
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let fraction = max(0, min(1, drag.location.x / geo.size.width))
                        let raw = Double(range.lowerBound) + fraction * Double(steps)
                        value = max(range.lowerBound, min(range.upperBound, Int(raw.rounded())))
                    }
            )
        }
        .frame(height: 30)
    }
}

// MARK: - Spin Wheel Drawing

struct SpinWheelView: View {
    @Environment(\.colorScheme) private var colorScheme
    private var t: Tide { .resolve(colorScheme) }

    let options: [WheelOption]

    private var totalWeight: Double {
        options.reduce(0) { $0 + Double($1.weight) }
    }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = size / 2

            ZStack {
                ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                    let start = startAngle(for: index)
                    let sweep = sliceAngle(for: option)
                    let drawStart = Angle.radians(start - .pi / 2)
                    let drawEnd = Angle.radians(start + sweep - .pi / 2)
                    let color = t.slices[index % t.slices.count]

                    Path { path in
                        path.move(to: center)
                        path.addArc(
                            center: center, radius: radius,
                            startAngle: drawStart, endAngle: drawEnd,
                            clockwise: false
                        )
                        path.closeSubpath()
                    }
                    .fill(color)

                    Path { path in
                        path.move(to: center)
                        path.addArc(
                            center: center, radius: radius,
                            startAngle: drawStart, endAngle: drawEnd,
                            clockwise: false
                        )
                        path.closeSubpath()
                    }
                    .stroke(t.surface, lineWidth: 1.5)

                    let mid = start + sweep / 2 - .pi / 2
                    let labelRadius = radius * 0.65

                    Text(option.label)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.4), radius: 1, x: 0.5, y: 0.5)
                        .rotationEffect(.radians(mid))
                        .position(
                            x: center.x + labelRadius * cos(mid),
                            y: center.y + labelRadius * sin(mid)
                        )
                }

                // Center hub
                Circle()
                    .fill(t.surface)
                    .frame(width: 44, height: 44)
                    .position(center)

                Circle()
                    .stroke(t.line, lineWidth: 0.5)
                    .frame(width: 44, height: 44)
                    .position(center)

                // Center accent dot
                Circle()
                    .fill(t.accent)
                    .frame(width: 12, height: 12)
                    .position(center)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func sliceAngle(for option: WheelOption) -> Double {
        guard totalWeight > 0 else { return 0 }
        return (Double(option.weight) / totalWeight) * 2 * .pi
    }

    private func startAngle(for index: Int) -> Double {
        options.prefix(index).reduce(0) { $0 + sliceAngle(for: $1) }
    }
}

#Preview {
    ContentView()
        .environment(AppData.sample())
}
