import Foundation
import Observation

public enum Route: Hashable, Sendable {
    case profile(userID: String)
    case postDetail(postID: String)
    case chatThread(chatID: String)
    case mediaViewer(id: String)
    case search(query: String?)
    case settings
    case security
    case privacy
}

public enum SheetDestination: Hashable, Identifiable, Sendable {
    case composer
    case editProfile
    case aiAssistant
    case storyViewer(storyID: String)
    case liveRoom(liveID: String)
    case attachmentPicker(chatID: String?)

    public var id: String {
        switch self {
        case .composer: "composer"
        case .editProfile: "editProfile"
        case .aiAssistant: "aiAssistant"
        case let .storyViewer(storyID): "storyViewer-\(storyID)"
        case let .liveRoom(liveID): "liveRoom-\(liveID)"
        case let .attachmentPicker(chatID): "attachmentPicker-\(chatID ?? "new")"
        }
    }
}

@MainActor
@Observable
public final class AppRouter {
    public var selectedTab: AppTab
    public var homePath: [Route]
    public var chatsPath: [Route]
    public var profilePath: [Route]
    public var presentedSheet: SheetDestination?

    public init(
        selectedTab: AppTab = .home,
        homePath: [Route] = [],
        chatsPath: [Route] = [],
        profilePath: [Route] = [],
        presentedSheet: SheetDestination? = nil
    ) {
        self.selectedTab = selectedTab
        self.homePath = homePath
        self.chatsPath = chatsPath
        self.profilePath = profilePath
        self.presentedSheet = presentedSheet
    }

    public func path(for tab: AppTab) -> [Route] {
        switch tab {
        case .home: homePath
        case .chats: chatsPath
        case .profile: profilePath
        }
    }

    public func push(_ route: Route, in tab: AppTab? = nil) {
        let target = tab ?? selectedTab
        selectedTab = target
        switch target {
        case .home: homePath.append(route)
        case .chats: chatsPath.append(route)
        case .profile: profilePath.append(route)
        }
    }

    public func present(_ sheet: SheetDestination) {
        presentedSheet = sheet
    }

    public func apply(_ handoff: IntentHandoff) {
        switch handoff {
        case let .openTab(tab):
            selectedTab = tab
        case let .composeDraft(text):
            selectedTab = .home
            presentedSheet = .composer
            DraftHandoffStorage.write(text)
        case let .openChat(chatID):
            push(.chatThread(chatID: chatID), in: .chats)
        case let .openProfile(userID):
            push(.profile(userID: userID), in: .profile)
        }
    }
}
