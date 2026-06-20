import AppCore
import Foundation

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

#if canImport(FirebaseStorage)
import FirebaseStorage
#endif

#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif

public actor FirebaseAuthAdapter: AuthService {
    private let configuration: AppRuntimeConfiguration

    public init(configuration: AppRuntimeConfiguration) {
        self.configuration = configuration
    }

    public func currentState() async -> AuthState {
        #if canImport(FirebaseAuth) && canImport(FirebaseCore)
        if FirebaseApp.app() != nil, Auth.auth().currentUser != nil {
            return .signedIn(Fixtures.currentUser)
        }
        #endif
        return .signedOut
    }

    public func startPhoneVerification(phone: String) async throws {
        guard configuration.firebaseProjectID != AppRuntimeConfiguration.placeholder.firebaseProjectID else {
            throw UnioServiceError.unconfigured("Firebase phone auth не настроен. Добавьте production GoogleService-Info.plist.")
        }
    }

    public func signIn(with provider: AuthProvider) async throws -> UserProfile {
        guard configuration.firebaseProjectID != AppRuntimeConfiguration.placeholder.firebaseProjectID else {
            throw UnioServiceError.unconfigured("OAuth через \(provider.title) требует Firebase provider configuration.")
        }
        return Fixtures.currentUser
    }

    public func confirmCode(_ code: String) async throws -> UserProfile {
        guard code.count == 6 else {
            throw UnioServiceError.validation("Введите шестизначный код.")
        }
        return Fixtures.currentUser
    }

    public func signOut() async throws {
        #if canImport(FirebaseAuth) && canImport(FirebaseCore)
        if FirebaseApp.app() != nil {
            try Auth.auth().signOut()
        }
        #endif
    }
}

public actor FirestoreFeedAdapter: FeedService {
    private let configuration: AppRuntimeConfiguration

    public init(configuration: AppRuntimeConfiguration) {
        self.configuration = configuration
    }

    public func loadFeed(cursor: String?, followingOnly: Bool) async throws -> FeedPage {
        guard configuration.firebaseProjectID != AppRuntimeConfiguration.placeholder.firebaseProjectID else {
            return FeedPage(posts: Fixtures.posts, nextCursor: nil)
        }
        throw UnioServiceError.unconfigured("Firestore feed queries require collection contracts from the external backend.")
    }

    public func publish(_ draft: DraftPost) async throws -> Post {
        guard !draft.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw UnioServiceError.validation("Публикация не может быть пустой.")
        }
        return Post(
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

public actor FirestoreChatAdapter: ChatService {
    private let configuration: AppRuntimeConfiguration

    public init(configuration: AppRuntimeConfiguration) {
        self.configuration = configuration
    }

    public func loadChats(cursor: String?) async throws -> ChatPage {
        guard configuration.firebaseProjectID != AppRuntimeConfiguration.placeholder.firebaseProjectID else {
            return ChatPage(chats: Fixtures.chats, nextCursor: nil)
        }
        throw UnioServiceError.unconfigured("Chat collection contracts must be supplied by the external backend.")
    }

    public func loadMessages(chatID: String, cursor: String?) async throws -> MessagePage {
        MessagePage(messages: Fixtures.messages, nextCursor: nil)
    }

    public func sendMessage(chatID: String, text: String, attachments: [MediaAttachment]) async throws -> Message {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !attachments.isEmpty else {
            throw UnioServiceError.validation("Сообщение не может быть пустым.")
        }
        return Message(
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

public actor FirebaseMediaAdapter: MediaService {
    private let configuration: AppRuntimeConfiguration

    public init(configuration: AppRuntimeConfiguration) {
        self.configuration = configuration
    }

    public func upload(_ attachment: MediaAttachment, data: Data) async throws -> MediaAttachment {
        guard configuration.firebaseProjectID != AppRuntimeConfiguration.placeholder.firebaseProjectID else {
            throw UnioServiceError.unconfigured("Firebase Storage не настроен для загрузки медиа.")
        }
        return attachment
    }

    public func cachedURL(for attachment: MediaAttachment) async -> URL? {
        attachment.remoteURL
    }
}

public actor FirebaseNotificationAdapter: NotificationService {
    private let configuration: AppRuntimeConfiguration

    public init(configuration: AppRuntimeConfiguration) {
        self.configuration = configuration
    }

    public func registerForPushNotifications() async throws {
        guard configuration.firebaseProjectID != AppRuntimeConfiguration.placeholder.firebaseProjectID else {
            throw UnioServiceError.unconfigured("FCM/APNs секреты не настроены.")
        }
    }

    public func updateDeviceToken(_ token: Data) async throws {}
}
