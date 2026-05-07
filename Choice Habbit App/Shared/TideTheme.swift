import SwiftUI

// MARK: - Theme Choice (auto / light / dark)

enum ThemeChoice: String, CaseIterable, Codable {
    case auto, light, dark

    var colorScheme: ColorScheme? {
        switch self {
        case .auto: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Tide Color Tokens

struct Tide {
    let bg: Color
    let surface: Color
    let surfaceAlt: Color
    let ink: Color
    let inkSoft: Color
    let inkMute: Color
    let line: Color
    let accent: Color
    let accentSoft: Color
    let accentInk: Color
    let warm: Color
    let ok: Color
    let slices: [Color]

    static let light = Tide(
        bg: Color(hex: 0xF2EEE6),
        surface: Color(hex: 0xFBF8F2),
        surfaceAlt: Color(hex: 0xEAE3D6),
        ink: Color(hex: 0x0F2A2E),
        inkSoft: Color(hex: 0x3A5256),
        inkMute: Color(hex: 0x7A8A8C),
        line: Color(hex: 0xD9D1BF),
        accent: Color(hex: 0x0E6E6E),
        accentSoft: Color(hex: 0x7DB7B0),
        accentInk: Color(hex: 0xFBF8F2),
        warm: Color(hex: 0xC97B4A),
        ok: Color(hex: 0x3D7A6B),
        slices: [0x0E6E6E, 0xC97B4A, 0x6E8E84, 0xA99578,
                 0x4F7A87, 0x8E6B4E, 0xB89A6E, 0x365A60].map { Color(hex: $0) }
    )

    static let dark = Tide(
        bg: Color(hex: 0x0B1719),
        surface: Color(hex: 0x13252A),
        surfaceAlt: Color(hex: 0x1B3035),
        ink: Color(hex: 0xEFE9DB),
        inkSoft: Color(hex: 0xB6C4C5),
        inkMute: Color(hex: 0x7A8A8C),
        line: Color(hex: 0x244046),
        accent: Color(hex: 0x5BC6BD),
        accentSoft: Color(hex: 0x2C7A78),
        accentInk: Color(hex: 0x0B1719),
        warm: Color(hex: 0xE0986A),
        ok: Color(hex: 0x79C7B4),
        slices: [0x5BC6BD, 0xE0986A, 0x9BB7A9, 0xC9B488,
                 0x6FA0AE, 0xB98F6E, 0xD9BD90, 0x3F8A8A].map { Color(hex: $0) }
    )

    static func resolve(_ cs: ColorScheme) -> Tide {
        cs == .dark ? .dark : .light
    }
}

// MARK: - Color Hex Initializer

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

// MARK: - Eyebrow Label

struct Eyebrow: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .tracking(2.0)
            .textCase(.uppercase)
            .foregroundStyle(color)
    }
}

// MARK: - Display Headline

struct TideHeadline: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 26, weight: .semibold, design: .rounded))
            .tracking(-0.8)
            .lineSpacing(-2)
            .foregroundStyle(color)
    }
}
