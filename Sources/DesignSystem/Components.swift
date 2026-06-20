import AppCore
import SwiftUI

public struct AvatarView: View {
    private let symbol: String
    private let size: CGFloat
    private let isStoryActive: Bool
    private let isViewed: Bool
    @Environment(\.unioPalette) private var palette

    public init(symbol: String, size: CGFloat = 48, isStoryActive: Bool = false, isViewed: Bool = false) {
        self.symbol = symbol
        self.size = size
        self.isStoryActive = isStoryActive
        self.isViewed = isViewed
    }

    public var body: some View {
        Text(symbol)
            .font(.system(size: size * 0.42, weight: .bold))
            .foregroundStyle(palette.inverseText)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(palette.inverseSurface)
            )
            .overlay {
                if isStoryActive {
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: isViewed ? [] : [7, 4]))
                        .foregroundStyle(isViewed ? palette.separator : palette.textPrimary)
                        .padding(-4)
                }
            }
            .accessibilityHidden(true)
    }
}

public struct VerifiedBadge: View {
    @Environment(\.unioPalette) private var palette

    public init() {}

    public var body: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 8, weight: .black))
            .foregroundStyle(palette.inverseText)
            .frame(width: 15, height: 15)
            .background(Circle().fill(palette.inverseSurface))
            .accessibilityLabel("Проверенный аккаунт")
    }
}

public struct IconActionButton: View {
    private let systemImage: String
    private let filledSystemImage: String
    private let title: String
    private let count: Int?
    private let isActive: Bool
    private let action: () -> Void
    @Environment(\.unioPalette) private var palette

    public init(
        systemImage: String,
        filledSystemImage: String,
        title: String,
        count: Int? = nil,
        isActive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.filledSystemImage = filledSystemImage
        self.title = title
        self.count = count
        self.isActive = isActive
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: isActive ? filledSystemImage : systemImage)
                    .font(.system(size: 16, weight: .medium))
                if let count {
                    Text(UnioFormatters.compactCount(count))
                        .font(UnioTypography.caption)
                }
            }
            .foregroundStyle(isActive ? palette.textPrimary : palette.textSecondary)
            .frame(minWidth: 36, minHeight: 32)
            .contentShape(Rectangle())
            .scaleEffect(isActive ? 1.06 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.68), value: isActive)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

public struct MonochromeCard<Content: View>: View {
    private let content: Content
    @Environment(\.unioPalette) private var palette

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(UnioSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: UnioRadius.md, style: .continuous)
                    .fill(palette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: UnioRadius.md, style: .continuous)
                    .stroke(palette.separator.opacity(0.8), lineWidth: 0.6)
            )
    }
}

public struct SkeletonBlock: View {
    private let height: CGFloat
    @Environment(\.unioPalette) private var palette

    public init(height: CGFloat) {
        self.height = height
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: UnioRadius.sm, style: .continuous)
            .fill(palette.raisedSurface)
            .frame(height: height)
            .redacted(reason: .placeholder)
            .accessibilityLabel("Загрузка")
    }
}

public struct PrimaryMonochromeButtonStyle: ButtonStyle {
    @Environment(\.unioPalette) private var palette

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .default, weight: .semibold))
            .foregroundStyle(configuration.isPressed ? palette.textPrimary : palette.inverseText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: UnioRadius.lg, style: .continuous)
                    .fill(configuration.isPressed ? palette.raisedSurface : palette.inverseSurface)
            )
            .animation(.spring(response: 0.24, dampingFraction: 0.74), value: configuration.isPressed)
    }
}

public struct SecondaryMonochromeButtonStyle: ButtonStyle {
    @Environment(\.unioPalette) private var palette

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .default, weight: .medium))
            .foregroundStyle(palette.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: UnioRadius.lg, style: .continuous)
                    .fill(configuration.isPressed ? palette.inverseSurface : palette.raisedSurface)
            )
            .foregroundStyle(configuration.isPressed ? palette.inverseText : palette.textPrimary)
    }
}
