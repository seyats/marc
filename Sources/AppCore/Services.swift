import Foundation
import Observation

public enum UnioServiceError: LocalizedError, Sendable {
    case unconfigured(String)
    case unauthorized
    case offline
    case validation(String)
    case transport(String)

    public var errorDescription: String? {
        switch self {
        case let .unconfigured(message): message
        case .unauthorized: "Необходимо войти в аккаунт."
        case .offline: "Нет подключения к сети."
        case let .validation(message): message
        case let .transport(message): message
        }
    }
}

public enum AuthState: Equatable, Sendable {
    case signedOut
    case phoneVerification(phone: String)
    case signedIn(UserProfile)
}

public enum AuthProvider: String, CaseIterable, Identifiable, Sendable {
    case apple
    case google
    case github

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .apple: "Apple"
        case .google: "Google"
        case .github: "GitHub"
        }
    }
}

public protocol AuthService: Sendable {
    func currentState() async -> AuthState
    func startPhoneVerification(phone: String) async throws
    func signIn(with provider: AuthProvider) async throws -> UserProfile
    func confirmCode(_ code: String) async throws -> UserProfile
    func signOut() async throws
}

public protocol FeedService: Sendable {
    func loadFeed(cursor: String?, followingOnly: Bool) async throws -> FeedPage
    func publish(_ draft: DraftPost) async throws -> Post
    func toggleLike(postID: String, isLiked: Bool) async throws
    func toggleBookmark(postID: String, isBookmarked: Bool) async throws
}

public protocol ChatService: Sendable {
    func loadChats(cursor: String?) async throws -> ChatPage
    func loadMessages(chatID: String, cursor: String?) async throws -> MessagePage
    func sendMessage(chatID: String, text: String, attachments: [MediaAttachment]) async throws -> Message
}

public protocol RealtimeService: Sendable {
    func connect() async throws
    func disconnect() async
    func subscribeToChat(_ chatID: String) async throws -> AsyncStream<Message>
}

public protocol MediaService: Sendable {
    func upload(_ attachment: MediaAttachment, data: Data) async throws -> MediaAttachment
    func cachedURL(for attachment: MediaAttachment) async -> URL?
}

public protocol NotificationService: Sendable {
    func registerForPushNotifications() async throws
    func updateDeviceToken(_ token: Data) async throws
}

public protocol LocalStore: Sendable {
    func savePosts(_ posts: [Post]) async throws
    func cachedPosts() async throws -> [Post]
    func saveChats(_ chats: [ChatSummary]) async throws
    func cachedChats() async throws -> [ChatSummary]
}

public protocol AIService: Sendable {
    func respond(to message: String, context: AIContext) async throws -> AIMessage
    func rewritePost(_ text: String) async throws -> String
    func translateMessage(_ text: String, targetLanguage: String) async throws -> String
}

public struct FeedPage: Sendable, Equatable {
    public var posts: [Post]
    public var nextCursor: String?

    public init(posts: [Post], nextCursor: String?) {
        self.posts = posts
        self.nextCursor = nextCursor
    }
}

public struct ChatPage: Sendable, Equatable {
    public var chats: [ChatSummary]
    public var nextCursor: String?

    public init(chats: [ChatSummary], nextCursor: String?) {
        self.chats = chats
        self.nextCursor = nextCursor
    }
}

public struct MessagePage: Sendable, Equatable {
    public var messages: [Message]
    public var nextCursor: String?

    public init(messages: [Message], nextCursor: String?) {
        self.messages = messages
        self.nextCursor = nextCursor
    }
}

public struct AIContext: Sendable, Equatable {
    public var userID: String
    public var localeIdentifier: String
    public var source: String

    public init(userID: String, localeIdentifier: String = "ru_RU", source: String) {
        self.userID = userID
        self.localeIdentifier = localeIdentifier
        self.source = source
    }
}

@MainActor
@Observable
public final class AppEnvironment {
    public let authService: any AuthService
    public let feedService: any FeedService
    public let chatService: any ChatService
    public let realtimeService: any RealtimeService
    public let mediaService: any MediaService
    public let notificationService: any NotificationService
    public let localStore: any LocalStore
    public let aiService: any AIService

    public init(
        authService: any AuthService,
        feedService: any FeedService,
        chatService: any ChatService,
        realtimeService: any RealtimeService,
        mediaService: any MediaService,
        notificationService: any NotificationService,
        localStore: any LocalStore,
        aiService: any AIService
    ) {
        self.authService = authService
        self.feedService = feedService
        self.chatService = chatService
        self.realtimeService = realtimeService
        self.mediaService = mediaService
        self.notificationService = notificationService
        self.localStore = localStore
        self.aiService = aiService
    }
}
