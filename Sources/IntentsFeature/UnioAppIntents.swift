import AppCore
import AppIntents
import Foundation

public enum UnioTabIntentValue: String, AppEnum {
    case home
    case chats
    case profile

    public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Раздел Unio")

    public static let caseDisplayRepresentations: [UnioTabIntentValue: DisplayRepresentation] = [
        .home: "Главная",
        .chats: "Чаты",
        .profile: "Профиль"
    ]

    var appTab: AppTab {
        switch self {
        case .home: .home
        case .chats: .chats
        case .profile: .profile
        }
    }
}

public struct OpenUnioTabIntent: AppIntent {
    public static let title: LocalizedStringResource = "Открыть раздел Unio"
    public static let description = IntentDescription("Открывает выбранный раздел приложения Unio.")
    public static var openAppWhenRun: Bool { true }

    @Parameter(title: "Раздел")
    public var tab: UnioTabIntentValue

    public init() {
        self.tab = .home
    }

    public init(tab: UnioTabIntentValue) {
        self.tab = tab
    }

    public func perform() async throws -> some IntentResult {
        IntentHandoffStorage.write(.openTab(tab.appTab))
        return .result(dialog: "Открываю \(tab.localizedTitle) в Unio.")
    }
}

public struct ComposeUnioPostIntent: AppIntent {
    public static let title: LocalizedStringResource = "Создать публикацию Unio"
    public static let description = IntentDescription("Открывает редактор публикации Unio с черновиком.")
    public static var openAppWhenRun: Bool { true }

    @Parameter(title: "Текст")
    public var text: String?

    public init() {
        self.text = nil
    }

    public init(text: String?) {
        self.text = text
    }

    public func perform() async throws -> some IntentResult {
        IntentHandoffStorage.write(.composeDraft(text: text))
        return .result(dialog: "Открываю редактор публикации.")
    }
}

public struct OpenUnioChatIntent: AppIntent {
    public static let title: LocalizedStringResource = "Открыть чат Unio"
    public static let description = IntentDescription("Открывает выбранный чат в Unio.")
    public static var openAppWhenRun: Bool { true }

    @Parameter(title: "Чат")
    public var chat: UnioChatEntity

    public init() {
        self.chat = UnioChatEntity.defaultValue
    }

    public init(chat: UnioChatEntity) {
        self.chat = chat
    }

    public func perform() async throws -> some IntentResult {
        IntentHandoffStorage.write(.openChat(chatID: chat.id))
        return .result(dialog: "Открываю чат \(chat.title).")
    }
}

public struct OpenUnioProfileIntent: AppIntent {
    public static let title: LocalizedStringResource = "Открыть профиль Unio"
    public static let description = IntentDescription("Открывает выбранный профиль в Unio.")
    public static var openAppWhenRun: Bool { true }

    @Parameter(title: "Профиль")
    public var profile: UnioProfileEntity

    public init() {
        self.profile = UnioProfileEntity.defaultValue
    }

    public init(profile: UnioProfileEntity) {
        self.profile = profile
    }

    public func perform() async throws -> some IntentResult {
        IntentHandoffStorage.write(.openProfile(userID: profile.id))
        return .result(dialog: "Открываю профиль \(profile.title).")
    }
}

extension UnioTabIntentValue {
    fileprivate var localizedTitle: String {
        switch self {
        case .home: "Главную"
        case .chats: "Чаты"
        case .profile: "Профиль"
        }
    }
}
