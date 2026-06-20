import SwiftUI

public struct GlassSurface<Content: View>: View {
    private let cornerRadius: CGFloat
    private let isInteractive: Bool
    private let content: Content
    @Environment(\.unioPalette) private var palette

    public init(
        cornerRadius: CGFloat = UnioRadius.lg,
        isInteractive: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.isInteractive = isInteractive
        self.content = content()
    }

    public var body: some View {
        GlassEffectContainer(spacing: UnioSpacing.sm) {
            content
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(palette.glassTint)
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(palette.separator.opacity(0.65), lineWidth: 0.7)
                    }
                )
                .glassEffect(.regular.interactive(isInteractive), in: .rect(cornerRadius: cornerRadius))
        }
    }
}

public struct FloatingGlassButton: View {
    private let systemImage: String
    private let accessibilityLabel: String
    private let action: () -> Void
    @Environment(\.unioPalette) private var palette

    public init(systemImage: String, accessibilityLabel: String, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
                .frame(width: 48, height: 48)
        }
        .buttonStyle(.glass)
        .accessibilityLabel(accessibilityLabel)
    }
}
