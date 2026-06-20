import AppCore
import SwiftUI

public struct UnioFloatingTabBar: View {
    @Binding private var selectedTab: AppTab
    @Environment(\.unioPalette) private var palette

    public init(selectedTab: Binding<AppTab>) {
        self._selectedTab = selectedTab
    }

    public var body: some View {
        GlassSurface(cornerRadius: 34, isInteractive: true) {
            HStack(spacing: 12) {
                ForEach(AppTab.allCases) { tab in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.68)) {
                            selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: selectedTab == tab ? tab.filledSystemImage : tab.systemImage)
                                .font(.system(size: 20, weight: selectedTab == tab ? .bold : .regular))
                                .scaleEffect(selectedTab == tab ? 1.13 : 1.0)
                            Text(tab.title)
                                .font(.system(size: 11, weight: selectedTab == tab ? .semibold : .regular))
                        }
                        .foregroundStyle(selectedTab == tab ? palette.textPrimary : palette.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(tab.title)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}
