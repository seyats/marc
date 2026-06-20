import Foundation

public struct UserProfile: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public var displayName: String
    public var username: String
    public var phoneOrStatus: String
    public var bio: String
    public var isVerified: Bool
    public var followersCount: Int
    public var followingCount: Int
    public var avatarSymbol: String

    public init(
        id: String,
        displayName: String,
        username: String,
        phoneOrStatus: String,
        bio: String,
        isVerified: Bool,
        followersCount: Int,
        followingCount: Int,
        avatarSymbol: String
    ) {
        self.id = id
        self.displayName = displayName
        self.username = username
        self.phoneOrStatus = phoneOrStatus
        self.bio = bio
        self.isVerified = isVerified
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.avatarSymbol = avatarSymbol
    }
}

public enum MediaKind: String, Codable, Hashable, Sendable {
    case image
    case video
    case linkPreview
    case voiceNote
    case file
}

public struct MediaAttachment: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public var kind: MediaKind
    public var title: String
    public var subtitle: String
    public var remoteURL: URL?
    public var thumbnailURL: URL?
    public var duration: TimeInterval?
    public var byteCount: Int64?

    public init(
        id: String,
        kind: MediaKind,
        title: String,
        subtitle: String,
        remoteURL: URL? = nil,
        thumbnailURL: URL? = nil,
        duration: TimeInterval? = nil,
        byteCount: Int64? = nil
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.remoteURL = remoteURL
        self.thumbnailURL = thumbnailURL
        self.duration = duration
        self.byteCount = byteCount
    }
}

public struct Post: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public var author: UserProfile
    public var text: String
    public var attachments: [MediaAttachment]
    public var createdAt: Date
    public var viewCount: Int
    public var replyCount: Int
    public var repostCount: Int
    public var likeCount: Int
    public var isLiked: Bool
    public var isBookmarked: Bool
    public var tags: [String]

    public init(
        id: String,
        author: UserProfile,
        text: String,
        attachments: [MediaAttachment],
        createdAt: Date,
        viewCount: Int,
        replyCount: Int,
        repostCount: Int,
        likeCount: Int,
        isLiked: Bool,
        isBookmarked: Bool,
        tags: [String]
    ) {
        self.id = id
        self.author = author
        self.text = text
        self.attachments = attachments
        self.createdAt = createdAt
        self.viewCount = viewCount
        self.replyCount = replyCount
        self.repostCount = repostCount
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.isBookmarked = isBookmarked
        self.tags = tags
    }
}

public struct Story: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public var author: UserProfile
    public var expiresAt: Date
    public var isViewed: Bool

    public init(id: String, author: UserProfile, expiresAt: Date, isViewed: Bool) {
        self.id = id
        self.author = author
        self.expiresAt = expiresAt
        self.isViewed = isViewed
    }
}

public enum ChatKind: String, Codable, Hashable, Sendable {
    case direct
    case group
    case channel
}

public struct ChatSummary: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public var kind: ChatKind
    public var title: String
    public var lastMessage: String
    public var lastActivityAt: Date
    public var unreadCount: Int
    public var isPinned: Bool
    public var isEncrypted: Bool
    public var avatarSymbol: String

    public init(
        id: String,
        kind: ChatKind,
        title: String,
        lastMessage: String,
        lastActivityAt: Date,
        unreadCount: Int,
        isPinned: Bool,
        isEncrypted: Bool,
        avatarSymbol: String
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.lastMessage = lastMessage
        self.lastActivityAt = lastActivityAt
        self.unreadCount = unreadCount
        self.isPinned = isPinned
        self.isEncrypted = isEncrypted
        self.avatarSymbol = avatarSymbol
    }
}

public enum MessageKind: String, Codable, Hashable, Sendable {
    case text
    case voice
    case video
    case file
    case system
}

public struct Message: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public var chatID: String
    public var author: UserProfile
    public var text: String
    public var kind: MessageKind
    public var attachments: [MediaAttachment]
    public var createdAt: Date
    public var isOutgoing: Bool
    public var isEdited: Bool
    public var replyToMessageID: String?

    public init(
        id: String,
        chatID: String,
        author: UserProfile,
        text: String,
        kind: MessageKind,
        attachments: [MediaAttachment],
        createdAt: Date,
        isOutgoing: Bool,
        isEdited: Bool,
        replyToMessageID: String? = nil
    ) {
        self.id = id
        self.chatID = chatID
        self.author = author
        self.text = text
        self.kind = kind
        self.attachments = attachments
        self.createdAt = createdAt
        self.isOutgoing = isOutgoing
        self.isEdited = isEdited
        self.replyToMessageID = replyToMessageID
    }
}

public struct CallSession: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public var chatID: String
    public var title: String
    public var startedAt: Date
    public var participantCount: Int
    public var isVideoEnabled: Bool

    public init(id: String, chatID: String, title: String, startedAt: Date, participantCount: Int, isVideoEnabled: Bool) {
        self.id = id
        self.chatID = chatID
        self.title = title
        self.startedAt = startedAt
        self.participantCount = participantCount
        self.isVideoEnabled = isVideoEnabled
    }
}

public struct DraftPost: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public var text: String
    public var attachments: [MediaAttachment]
    public var visibility: String

    public init(id: String = UUID().uuidString, text: String, attachments: [MediaAttachment] = [], visibility: String = "Публично") {
        self.id = id
        self.text = text
        self.attachments = attachments
        self.visibility = visibility
    }
}

public struct AIConversation: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public var title: String
    public var messages: [AIMessage]

    public init(id: String, title: String, messages: [AIMessage]) {
        self.id = id
        self.title = title
        self.messages = messages
    }
}

public struct AIMessage: Identifiable, Codable, Hashable, Sendable {
    public enum Role: String, Codable, Hashable, Sendable {
        case user
        case assistant
    }

    public let id: String
    public var role: Role
    public var text: String
    public var createdAt: Date

    public init(id: String = UUID().uuidString, role: Role, text: String, createdAt: Date = .now) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}
