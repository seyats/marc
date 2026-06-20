import SwiftUI

public enum ThemeMode: String, CaseIterable, Identifiable, Sendable {
    case light
    case dark

    public var id: String { rawValue }
}

public struct UnioPalette: Sendable {
    public var background: Color
    public var surface: Color
    public var raisedSurface: Color
    public var textPrimary: Color
    public var textSecondary: Color
    public var separator: Color
    public var inverseText: Color
    public var inverseSurface: Color
    public var glassTint: Color

    public static let light = UnioPalette(
        background: .white,
        surface: Color(white: 0.975),
        raisedSurface: Color(white: 0.94),
        textPrimary: .black,
        textSecondary: Color(white: 0.36),
        separator: Color(white: 0.84),
        inverseText: .white,
        inverseSurface: .black,
        glassTint: Color.white.opacity(0.36)
    )

    public static let dark = UnioPalette(
        background: .black,
        surface: Color(white: 0.055),
        raisedSurface: Color(white: 0.11),
        textPrimary: .white,
        textSecondary: Color(white: 0.66),
        separator: Color(white: 0.22),
        inverseText: .black,
        inverseSurface: .white,
        glassTint: Color.black.opacity(0.28)
    )
}

public enum UnioSpacing {
    public static let xxs: CGFloat = 4
    public static let xs: CGFloat = 8
    public static let sm: CGFloat = 12
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
}

public enum UnioRadius {
    public static let sm: CGFloat = 10
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
    public static let pill: CGFloat = 999
}

public enum UnioTypography {
    public static let title = Font.system(.largeTitle, design: .default, weight: .bold)
    public static let section = Font.system(.title3, design: .default, weight: .semibold)
    public static let body = Font.system(.body, design: .default, weight: .regular)
    public static let callout = Font.system(.callout, design: .default, weight: .medium)
    public static let caption = Font.system(.caption, design: .default, weight: .regular)
}

private struct UnioPaletteKey: EnvironmentKey {
    static let defaultValue = UnioPalette.light
}

public extension EnvironmentValues {
    var unioPalette: UnioPalette {
        get { self[UnioPaletteKey.self] }
        set { self[UnioPaletteKey.self] = newValue }
    }
}

public extension View {
    func unioTheme(_ mode: ThemeMode) -> some View {
        environment(\.unioPalette, mode == .dark ? .dark : .light)
            .preferredColorScheme(mode == .dark ? .dark : .light)
    }
}
