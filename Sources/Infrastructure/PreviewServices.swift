import AppCore
import Foundation

public actor PreviewAuthService: AuthService {
    public init() {}

    public func currentState() async -> AuthState {
        .signedIn(Fixtures.currentUser)
    }

    public func startPhoneVerification(phone: String) async throws {}

    public func signIn(with provider: AuthProvider) async throws -> UserProfile {
        Fixtures.currentUser
    }

    public func confirmCode(_ code: String) async throws -> UserProfile {
        Fixtures.currentUser
    }

    public func signOut() async throws {}
}

public actor PreviewFeedService: FeedService {
    public init() {}

    public func loadFeed(cursor: String?, followingOnly: Bool) async throws -> FeedPage {
        FeedPage(posts: Fixtures.posts, nextCursor: nil)
    }

    public func publish(_ draft: DraftPost) async throws -> Post {
        Post(
            id: UUID().uuidString,
            author: Fixtures.currentUser,
            text: draft.text,
            attachments: draft.attachments,
            createdAt: .now,
            viewCount: 0,
            replyCount: 0,
            repostCount: 0,
            likeCount: 0,
            isLiked: false,
            isBookmarked: false,
            tags: []
        )
    }

    public func toggleLike(postID: String, isLiked: Bool) async throws {}

    public func toggleBookmark(postID: String, isBookmarked: Bool) async throws {}
}

public actor PreviewChatService: ChatService {
    public init() {}

    public func loadChats(cursor: String?) async throws -> ChatPage {
        ChatPage(chats: Fixtures.chats, nextCursor: nil)
    }

    public func loadMessages(chatID: String, cursor: String?) async throws -> MessagePage {
        MessagePage(messages: Fixtures.messages.filter { $0.chatID == chatID || chatID == "chat-1" }, nextCursor: nil)
    }

    public func sendMessage(chatID: String, text: String, attachments: [MediaAttachment]) async throws -> Message {
        Message(
            id: UUID().uuidString,
            chatID: chatID,
            author: Fixtures.currentUser,
            text: text,
            kind: attachments.isEmpty ? .text : .file,
            attachments: attachments,
            createdAt: .now,
            isOutgoing: true,
            isEdited: false
        )
    }
}

public actor PreviewRealtimeService: RealtimeService {
    public init() {}

    public func connect() async throws {}

    public func disconnect() async {}

    public func subscribeToChat(_ chatID: String) async throws -> AsyncStream<Message> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }
}

public actor PreviewMediaService: MediaService {
    public init() {}

    public func upload(_ attachment: MediaAttachment, data: Data) async throws -> MediaAttachment {
        attachment
    }

    public func cachedURL(for attachment: MediaAttachment) async -> URL? {
        attachment.remoteURL
    }
}

public actor PreviewNotificationService: NotificationService {
    public init() {}

    public func registerForPushNotifications() async throws {}

    public func updateDeviceToken(_ token: Data) async throws {}
}

public actor PreviewLocalStore: LocalStore {
    private var posts: [Post] = Fixtures.posts
    private var chats: [ChatSummary] = Fixtures.chats

    public init() {}

    public func savePosts(_ posts: [Post]) async throws {
        self.posts = posts
    }

    public func cachedPosts() async throws -> [Post] {
        posts
    }

    public func saveChats(_ chats: [ChatSummary]) async throws {
        self.chats = chats
    }

    public func cachedChats() async throws -> [ChatSummary] {
        chats
    }
}

public actor PreviewAIService: AIService {
    public init() {}

    public func respond(to message: String, context: AIContext) async throws -> AIMessage {
        AIMessage(role: .assistant, text: "Черновик готов: \(message)")
    }

    public func rewritePost(_ text: String) async throws -> String {
        "Коротко и ясно: \(text)"
    }

    public func translateMessage(_ text: String, targetLanguage: String) async throws -> String {
        text
    }
}
