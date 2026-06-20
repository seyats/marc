import UIKit

public enum UnioHaptics {
    @MainActor
    public static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    @MainActor
    public static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    @MainActor
    public static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
