import SwiftUI

public struct UnioTopBar<Trailing: View>: View {
    private let title: String
    private let trailing: Trailing
    @Environment(\.unioPalette) private var palette

    public init(title: String, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.trailing = trailing()
    }

    public var body: some View {
        GlassSurface(cornerRadius: 28, isInteractive: false) {
            HStack {
                Text(title)
                    .font(.system(.title2, design: .default, weight: .bold))
                    .foregroundStyle(palette.textPrimary)
                Spacer()
                trailing
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
