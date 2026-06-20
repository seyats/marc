import Foundation

public enum IntentHandoff: Codable, Equatable, Sendable {
    case openTab(AppTab)
    case composeDraft(text: String?)
    case openChat(chatID: String)
    case openProfile(userID: String)
}

public enum IntentHandoffStorage {
    public static let storageKey = "unio.pendingIntentHandoff"
    public static let appGroupIdentifierKey = "UNIO_APP_GROUP"

    public static func write(_ handoff: IntentHandoff) {
        guard let data = try? JSONEncoder().encode(handoff) else { return }
        defaults.set(data, forKey: storageKey)
    }

    public static func consume() -> IntentHandoff? {
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        defaults.removeObject(forKey: storageKey)
        return try? JSONDecoder().decode(IntentHandoff.self, from: data)
    }

    private static var defaults: UserDefaults {
        guard
            let identifier = Bundle.main.object(forInfoDictionaryKey: appGroupIdentifierKey) as? String,
            let shared = UserDefaults(suiteName: identifier)
        else {
            return .standard
        }
        return shared
    }
}

public enum DraftHandoffStorage {
    public static let storageKey = "unio.pendingDraftText"

    public static func write(_ text: String?) {
        IntentSharedDefaults.defaults.set(text, forKey: storageKey)
    }

    public static func consume() -> String? {
        let text = IntentSharedDefaults.defaults.string(forKey: storageKey)
        IntentSharedDefaults.defaults.removeObject(forKey: storageKey)
        return text
    }
}

private enum IntentSharedDefaults {
    static var defaults: UserDefaults {
        guard
            let identifier = Bundle.main.object(forInfoDictionaryKey: IntentHandoffStorage.appGroupIdentifierKey) as? String,
            let shared = UserDefaults(suiteName: identifier)
        else {
            return .standard
        }
        return shared
    }
}
