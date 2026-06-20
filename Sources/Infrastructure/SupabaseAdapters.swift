import AppCore
import Foundation

#if canImport(Supabase)
import Supabase
#endif

public actor SupabaseClientProvider {
#if canImport(Supabase)
    public let client: SupabaseClient?
#else
    public let client: Any?
#endif
    public let configuration: SupabaseRuntimeConfiguration

    public init(configuration: SupabaseRuntimeConfiguration) {
        self.configuration = configuration
        #if canImport(Supabase)
        if configuration.isConfigured {
            self.client = SupabaseClient(
                supabaseURL: configuration.supabaseURL,
                supabaseKey: configuration.supabaseAnonKey
            )
        } else {
            self.client = nil
        }
        #else
        self.client = nil
        #endif
    }
}

public struct SupabaseProfileRecord: Codable, Sendable {
    public var id: String
    public var displayName: String
    public var username: String
    public var phoneOrStatus: String
    public var bio: String
    public var isVerified: Bool
    public var followersCount: Int
    public var followingCount: Int
    public var avatarSymbol: String
}

public struct SupabaseChatRecord: Codable, Sendable {
    public var id: String
    public var kind: String
    public var title: String
    public var lastMessage: String
    public var lastActivityAt: String
    public var unreadCount: Int
    public var isPinned: Bool
    public var isEncrypted: Bool
    public var avatarSymbol: String
}

public struct SupabaseAttachmentRecord: Codable, Sendable {
    public var id: String
    public var kind: String
    public var title: String
    public var subtitle: String
    public var remoteURL: String?
    public var thumbnailURL: String?
    public var duration: Double?
    public var byteCount: Int64?
}

public struct SupabaseMessageRecord: Codable, Sendable {
    public var id: String
    public var chatID: String
    public var authorID: String?
    public var authorDisplayName: String
    public var authorUsername: String
    public var authorPhoneOrStatus: String
    public var authorBio: String
    public var authorVerified: Bool
    public var authorFollowersCount: Int
    public var authorFollowingCount: Int
    public var authorAvatarSymbol: String
    public var text: String
    public var kind: String
    public var attachments: [SupabaseAttachmentRecord]
    public var createdAt: String
    public var isOutgoing: Bool
    public var isEdited: Bool
    public var replyToMessageID: String?
}

public struct SupabasePostRecord: Codable, Sendable {
    public var id: String
    public var authorID: String
    public var authorDisplayName: String
    public var authorUsername: String
    public var authorPhoneOrStatus: String
    public var authorBio: String
    public var authorVerified: Bool
    public var authorFollowersCount: Int
    public var authorFollowingCount: Int
    public var authorAvatarSymbol: String
    public var text: String
    public var attachments: [SupabaseAttachmentRecord]
    public var createdAt: String
    public var viewCount: Int
    public var replyCount: Int
    public var repostCount: Int
    public var likeCount: Int
    public var isLiked: Bool
    public var isBookmarked: Bool
    public var tags: [String]
}

private extension SupabaseProfileRecord {
    var model: UserProfile {
        UserProfile(
            id: id,
            displayName: displayName,
            username: username,
            phoneOrStatus: phoneOrStatus,
            bio: bio,
            isVerified: isVerified,
            followersCount: followersCount,
            followingCount: followingCount,
            avatarSymbol: avatarSymbol
        )
    }
}

private extension SupabaseChatRecord {
    var model: ChatSummary {
        ChatSummary(
            id: id,
            kind: ChatKind(rawValue: kind) ?? .direct,
            title: title,
            lastMessage: lastMessage,
            lastActivityAt: SupabaseDateCodec.decode(lastActivityAt),
            unreadCount: unreadCount,
            isPinned: isPinned,
            isEncrypted: isEncrypted,
            avatarSymbol: avatarSymbol
        )
    }
}

private extension SupabaseAttachmentRecord {
    var model: MediaAttachment {
        MediaAttachment(
            id: id,
            kind: MediaKind(rawValue: kind) ?? .file,
            title: title,
            subtitle: subtitle,
            remoteURL: remoteURL.flatMap(URL.init(string:)),
            thumbnailURL: thumbnailURL.flatMap(URL.init(string:)),
            duration: duration,
            byteCount: byteCount
        )
    }
}

private extension SupabaseMessageRecord {
    var model: AppCore.Message {
        AppCore.Message(
            id: id,
            chatID: chatID,
            author: UserProfile(
                id: authorID ?? UUID().uuidString,
                displayName: authorDisplayName,
                username: authorUsername,
                phoneOrStatus: authorPhoneOrStatus,
                bio: authorBio,
                isVerified: authorVerified,
                followersCount: authorFollowersCount,
                followingCount: authorFollowingCount,
                avatarSymbol: authorAvatarSymbol
            ),
            text: text,
            kind: MessageKind(rawValue: kind) ?? .text,
            attachments: attachments.map(\.model),
            createdAt: SupabaseDateCodec.decode(createdAt),
            isOutgoing: isOutgoing,
            isEdited: isEdited,
            replyToMessageID: replyToMessageID
        )
    }
}

private extension SupabasePostRecord {
    var model: Post {
        Post(
            id: id,
            author: UserProfile(
                id: authorID,
                displayName: authorDisplayName,
                username: authorUsername,
                phoneOrStatus: authorPhoneOrStatus,
                bio: authorBio,
                isVerified: authorVerified,
                followersCount: authorFollowersCount,
                followingCount: authorFollowingCount,
                avatarSymbol: authorAvatarSymbol
            ),
            text: text,
            attachments: attachments.map(\.model),
            createdAt: SupabaseDateCodec.decode(createdAt),
            viewCount: viewCount,
            replyCount: replyCount,
            repostCount: repostCount,
            likeCount: likeCount,
            isLiked: isLiked,
            isBookmarked: isBookmarked,
            tags: tags
        )
    }
}

public actor SupabaseAuthAdapter: AuthService {
    private let provider: SupabaseClientProvider
    private let configuration: SupabaseRuntimeConfiguration
    private var pendingPhone: String?

    public init(configuration: SupabaseRuntimeConfiguration) {
        self.provider = SupabaseClientProvider(configuration: configuration)
        self.configuration = configuration
    }

    public func currentState() async -> AuthState {
#if canImport(Supabase)
        guard let client = await provider.client, configuration.isConfigured else {
            return .signedOut
        }
        do {
            let session = try await client.auth.session
            let user = session.user
            if let profile = try await loadProfile(id: user.id, client: client) {
                return .signedIn(profile)
            }
            return .signedIn(profileFrom(user: user))
        } catch {
            return .signedOut
        }
#else
        return .signedIn(Fixtures.currentUser)
#endif
    }

    public func startPhoneVerification(phone: String) async throws {
#if canImport(Supabase)
        pendingPhone = phone
        guard let client = await provider.client else { return }
        try await client.auth.signInWithOTP(phone: phone)
#endif
    }

    public func signIn(with provider: AuthProvider) async throws -> UserProfile {
#if canImport(Supabase)
        guard let client = await self.provider.client else {
            return Fixtures.currentUser
        }
        switch provider {
        case .apple:
            throw UnioServiceError.unconfigured("OAuth Apple потребует redirect scheme и дополнительную настройку Supabase.")
        case .google:
            throw UnioServiceError.unconfigured("OAuth Google потребует redirect scheme и дополнительную настройку Supabase.")
        case .github:
            throw UnioServiceError.unconfigured("OAuth GitHub потребует redirect scheme и дополнительную настройку Supabase.")
        }
#else
        return Fixtures.currentUser
#endif
    }

    public func confirmCode(_ code: String) async throws -> UserProfile {
#if canImport(Supabase)
        guard let client = await provider.client else {
            return Fixtures.currentUser
        }
        guard let phone = pendingPhone else {
            throw UnioServiceError.validation("Сначала запросите код подтверждения.")
        }
        _ = try await client.auth.verifyOTP(phone: phone, token: code, type: .sms)
        pendingPhone = nil
        if let user = try? await client.auth.user(), let profile = try await loadProfile(id: user.id, client: client) {
            return profile
        }
        if let user = try? await client.auth.user() {
            return profileFrom(user: user)
        }
        return Fixtures.currentUser
#else
        return Fixtures.currentUser
#endif
    }

    public func signOut() async throws {
#if canImport(Supabase)
        pendingPhone = nil
        guard let client = await provider.client else { return }
        try await client.auth.signOut()
#endif
    }

#if canImport(Supabase)
    private func loadProfile(id: String, client: SupabaseClient) async throws -> UserProfile? {
        do {
            let profile: SupabaseProfileRecord = try await client
                .from("profiles")
                .select()
                .eq("id", value: id)
                .limit(1)
                .single()
                .execute()
                .value
            return profile.model
        } catch {
            return nil
        }
    }

    private func profileFrom(user: User) -> UserProfile {
        let metadata = user.userMetadata
        let displayName = metadataString(metadata, keys: ["display_name", "full_name", "name"]) ?? "Unio User"
        let username = metadataString(metadata, keys: ["username"]) ?? "@unio"
        let avatar = (displayName.first.map { String($0) } ?? "U")
        return UserProfile(
            id: user.id.uuidString,
            displayName: displayName,
            username: username,
            phoneOrStatus: user.phone ?? "В сети",
            bio: metadataString(metadata, keys: ["bio"]) ?? "",
            isVerified: false,
            followersCount: 0,
            followingCount: 0,
            avatarSymbol: avatar
        )
    }

    private func metadataString(_ metadata: [String: AnyJSON], keys: [String]) -> String? {
        for key in keys {
            guard let value = metadata[key], let string = stringValue(from: value) else { continue }
            return string
        }
        return nil
    }

    private func stringValue(from jsonValue: AnyJSON) -> String? {
        guard let data = try? JSONEncoder().encode(jsonValue) else {
            return nil
        }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) else {
            return nil
        }
        if let string = jsonObject as? String {
            return string
        }
        if let number = jsonObject as? NSNumber {
            return number.stringValue
        }
        return nil
    }
#endif
}

public actor SupabaseFeedAdapter: FeedService {
    private let provider: SupabaseClientProvider
    private let configuration: SupabaseRuntimeConfiguration
    private let currentUser: @Sendable () async -> UserProfile

    public init(
        configuration: SupabaseRuntimeConfiguration,
        currentUser: @escaping @Sendable () async -> UserProfile = { Fixtures.currentUser }
    ) {
        self.provider = SupabaseClientProvider(configuration: configuration)
        self.configuration = configuration
        self.currentUser = currentUser
    }

    public func loadFeed(cursor: String?, followingOnly: Bool) async throws -> FeedPage {
#if canImport(Supabase)
        guard let client = await provider.client, configuration.isConfigured else {
            return FeedPage(posts: Fixtures.posts, nextCursor: nil)
        }
        let posts: [SupabasePostRecord] = try await client
            .from(configuration.postsTable)
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
        return FeedPage(posts: posts.map(\.model), nextCursor: nil)
#else
        return FeedPage(posts: Fixtures.posts, nextCursor: nil)
#endif
    }

    public func publish(_ draft: DraftPost) async throws -> Post {
        let author = await currentUser()
#if canImport(Supabase)
        guard let client = await provider.client, configuration.isConfigured else {
            return Post(
                id: UUID().uuidString,
                author: author,
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
        let record = SupabasePostRecord(
            id: UUID().uuidString,
            authorID: author.id,
            authorDisplayName: author.displayName,
            authorUsername: author.username,
            authorPhoneOrStatus: author.phoneOrStatus,
            authorBio: author.bio,
            authorVerified: author.isVerified,
            authorFollowersCount: author.followersCount,
            authorFollowingCount: author.followingCount,
            authorAvatarSymbol: author.avatarSymbol,
            text: draft.text,
            attachments: draft.attachments.map {
                SupabaseAttachmentRecord(
                    id: $0.id,
                    kind: $0.kind.rawValue,
                    title: $0.title,
                    subtitle: $0.subtitle,
                    remoteURL: $0.remoteURL?.absoluteString,
                    thumbnailURL: $0.thumbnailURL?.absoluteString,
                    duration: $0.duration,
                    byteCount: $0.byteCount
                )
            },
            createdAt: SupabaseDateCodec.encode(.now),
            viewCount: 0,
            replyCount: 0,
            repostCount: 0,
            likeCount: 0,
            isLiked: false,
            isBookmarked: false,
            tags: []
        )
        let inserted: SupabasePostRecord = try await client
            .from(configuration.postsTable)
            .insert(record)
            .select()
            .single()
            .execute()
            .value
        return inserted.model
#else
        return Post(
            id: UUID().uuidString,
            author: author,
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
#endif
    }

    public func toggleLike(postID: String, isLiked: Bool) async throws {}

    public func toggleBookmark(postID: String, isBookmarked: Bool) async throws {}
}

public actor SupabaseChatAdapter: ChatService {
    private let provider: SupabaseClientProvider
    private let configuration: SupabaseRuntimeConfiguration
    private let currentUser: @Sendable () async -> UserProfile

    public init(
        configuration: SupabaseRuntimeConfiguration,
        currentUser: @escaping @Sendable () async -> UserProfile = { Fixtures.currentUser }
    ) {
        self.provider = SupabaseClientProvider(configuration: configuration)
        self.configuration = configuration
        self.currentUser = currentUser
    }

    public func loadChats(cursor: String?) async throws -> ChatPage {
#if canImport(Supabase)
        guard let client = await provider.client, configuration.isConfigured else {
            return ChatPage(chats: Fixtures.chats, nextCursor: nil)
        }
        let rows: [SupabaseChatRecord] = try await client
            .from(configuration.chatsTable)
            .select()
            .order("last_activity_at", ascending: false)
            .execute()
            .value
        return ChatPage(chats: rows.map(\.model), nextCursor: nil)
#else
        return ChatPage(chats: Fixtures.chats, nextCursor: nil)
#endif
    }

    public func loadMessages(chatID: String, cursor: String?) async throws -> MessagePage {
#if canImport(Supabase)
        guard let client = await provider.client, configuration.isConfigured else {
            let messages = Fixtures.messages.filter { $0.chatID == chatID }
            return MessagePage(messages: messages.isEmpty ? Fixtures.messages.filter { $0.chatID == "chat-1" } : messages, nextCursor: nil)
        }
        let rows: [SupabaseMessageRecord] = try await client
            .from(configuration.messagesTable)
            .select()
            .eq("chat_id", value: chatID)
            .order("created_at", ascending: true)
            .execute()
            .value
        return MessagePage(messages: rows.map(\.model), nextCursor: nil)
#else
        let messages = Fixtures.messages.filter { $0.chatID == chatID }
        return MessagePage(messages: messages.isEmpty ? Fixtures.messages.filter { $0.chatID == "chat-1" } : messages, nextCursor: nil)
#endif
    }

    public func sendMessage(chatID: String, text: String, attachments: [MediaAttachment]) async throws -> AppCore.Message {
        let author = await currentUser()
        let message = AppCore.Message(
            id: UUID().uuidString,
            chatID: chatID,
            author: author,
            text: text,
            kind: attachments.isEmpty ? .text : .file,
            attachments: attachments,
            createdAt: .now,
            isOutgoing: true,
            isEdited: false
        )
#if canImport(Supabase)
        guard let client = await provider.client, configuration.isConfigured else {
            return message
        }
        let record = SupabaseMessageRecord(
            id: message.id,
            chatID: chatID,
            authorID: message.author.id,
            authorDisplayName: message.author.displayName,
            authorUsername: message.author.username,
            authorPhoneOrStatus: message.author.phoneOrStatus,
            authorBio: message.author.bio,
            authorVerified: message.author.isVerified,
            authorFollowersCount: message.author.followersCount,
            authorFollowingCount: message.author.followingCount,
            authorAvatarSymbol: message.author.avatarSymbol,
            text: message.text,
            kind: message.kind.rawValue,
            attachments: message.attachments.map {
                SupabaseAttachmentRecord(
                    id: $0.id,
                    kind: $0.kind.rawValue,
                    title: $0.title,
                    subtitle: $0.subtitle,
                    remoteURL: $0.remoteURL?.absoluteString,
                    thumbnailURL: $0.thumbnailURL?.absoluteString,
                    duration: $0.duration,
                    byteCount: $0.byteCount
                )
            },
            createdAt: SupabaseDateCodec.encode(message.createdAt),
            isOutgoing: true,
            isEdited: false,
            replyToMessageID: nil
        )
        let inserted: SupabaseMessageRecord = try await client
            .from(configuration.messagesTable)
            .insert(record)
            .select()
            .single()
            .execute()
            .value
        return inserted.model
#else
        return message
#endif
    }
}

public actor SupabaseMediaAdapter: MediaService {
    private let provider: SupabaseClientProvider
    private let configuration: SupabaseRuntimeConfiguration

    public init(configuration: SupabaseRuntimeConfiguration) {
        self.provider = SupabaseClientProvider(configuration: configuration)
        self.configuration = configuration
    }

    public func upload(_ attachment: MediaAttachment, data: Data) async throws -> MediaAttachment {
#if canImport(Supabase)
        guard let client = await provider.client, configuration.isConfigured else {
            return attachment
        }
        let fileName = "\(attachment.id).bin"
        _ = try await client.storage
            .from(configuration.storageBucket)
            .upload(
                path: "public/\(fileName)",
                file: data,
                options: FileOptions(
                    cacheControl: "3600",
                    contentType: "application/octet-stream",
                    upsert: true
                )
            )
        let publicURL = try client.storage
            .from(configuration.storageBucket)
            .getPublicURL(path: "public/\(fileName)")
        return MediaAttachment(
            id: attachment.id,
            kind: attachment.kind,
            title: attachment.title,
            subtitle: attachment.subtitle,
            remoteURL: publicURL,
            thumbnailURL: attachment.thumbnailURL,
            duration: attachment.duration,
            byteCount: attachment.byteCount
        )
#else
        return attachment
#endif
    }

    public func cachedURL(for attachment: MediaAttachment) async -> URL? {
        attachment.remoteURL
    }
}

public actor SupabaseNotificationAdapter: NotificationService {
    public init(configuration: SupabaseRuntimeConfiguration) {}

    public func registerForPushNotifications() async throws {}

    public func updateDeviceToken(_ token: Data) async throws {}
}

public actor SupabaseRealtimeAdapter: RealtimeService {
    private let provider: SupabaseClientProvider
    private let configuration: SupabaseRuntimeConfiguration

    public init(configuration: SupabaseRuntimeConfiguration) {
        self.provider = SupabaseClientProvider(configuration: configuration)
        self.configuration = configuration
    }

    public func connect() async throws {}

    public func disconnect() async {}

    public func subscribeToChat(_ chatID: String) async throws -> AsyncStream<AppCore.Message> {
#if canImport(Supabase)
        guard let client = await provider.client, configuration.isConfigured else {
            return AsyncStream { continuation in
                continuation.finish()
            }
        }
        return AsyncStream { continuation in
            let channel = client.channel("chat-\(chatID)")
            channel.onPostgresChange(InsertAction.self, schema: "public", table: configuration.messagesTable) { change in
                do {
                    let record = try change.decodeRecord(as: SupabaseMessageRecord.self, decoder: JSONDecoder())
                    guard record.chatID == chatID else { return }
                    continuation.yield(record.model)
                } catch {
                    return
                }
            }
            let task = Task {
                await channel.subscribe()
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
                Task {
                    await client.realtimeV2.removeChannel(channel)
                }
            }
        }
#else
        return AsyncStream { continuation in
            continuation.finish()
        }
#endif
    }
}
