import Foundation

public enum UnioFormatters {
    public static func compactCount(_ value: Int) -> String {
        if value >= 1_000_000 {
            String(format: "%.1f млн", Double(value) / 1_000_000)
        } else if value >= 1_000 {
            String(format: "%.1f тыс.", Double(value) / 1_000)
        } else {
            "\(value)"
        }
    }

    public static func relativeTime(_ date: Date, now: Date = .now) -> String {
        let seconds = max(0, Int(now.timeIntervalSince(date)))
        if seconds < 60 { return "только что" }
        if seconds < 3_600 { return "\(seconds / 60) мин" }
        if seconds < 86_400 { return "\(seconds / 3_600) ч" }
        return "\(seconds / 86_400) д"
    }
}
