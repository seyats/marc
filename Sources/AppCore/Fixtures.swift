import Foundation

public enum Fixtures {
    public static let currentUser = UserProfile(
        id: "user-current",
        displayName: "Анна Волкова",
        username: "@anna",
        phoneOrStatus: "В сети",
        bio: "Дизайнер, автор, собираю вокруг Unio спокойные сообщества.",
        isVerified: true,
        followersCount: 12840,
        followingCount: 314,
        avatarSymbol: "A"
    )

    public static let creator = UserProfile(
        id: "user-creator",
        displayName: "Марк Лебедев",
        username: "@mark",
        phoneOrStatus: "Создатель контента",
        bio: "Пишу о продуктах, культуре и технологиях.",
        isVerified: true,
        followersCount: 245000,
        followingCount: 811,
        avatarSymbol: "M"
    )

    public static let editor = UserProfile(
        id: "user-editor",
        displayName: "Лера Соколова",
        username: "@lera",
        phoneOrStatus: "Редактор",
        bio: "Подбираю хорошие истории и тихие смыслы.",
        isVerified: false,
        followersCount: 42000,
        followingCount: 522,
        avatarSymbol: "Л"
    )

    public static let posts: [Post] = [
        Post(
            id: "post-1",
            author: creator,
            text: "Unio должен ощущаться как одно цельное место: быстрые чаты, спокойная лента, истории и эфиры без визуального шума.",
            attachments: [
                MediaAttachment(
                    id: "media-1",
                    kind: .image,
                    title: "Монохромный прототип",
                    subtitle: "Стеклянная навигация поверх ленты"
                )
            ],
            createdAt: Date(timeIntervalSinceNow: -1800),
            viewCount: 48200,
            replyCount: 184,
            repostCount: 390,
            likeCount: 12400,
            isLiked: true,
            isBookmarked: false,
            tags: ["#Unio", "#дизайн"]
        ),
        Post(
            id: "post-2",
            author: editor,
            text: "Хорошая социальная сеть не должна кричать. Она должна помогать говорить, слушать и возвращаться к важному.",
            attachments: [
                MediaAttachment(
                    id: "media-2",
                    kind: .linkPreview,
                    title: "Манифест спокойного интерфейса",
                    subtitle: "unio.app/journal/calm-social"
                )
            ],
            createdAt: Date(timeIntervalSinceNow: -5400),
            viewCount: 17800,
            replyCount: 62,
            repostCount: 91,
            likeCount: 3100,
            isLiked: false,
            isBookmarked: true,
            tags: ["#сообщество"]
        )
    ]

    public static let stories: [Story] = [
        Story(id: "story-current", author: currentUser, expiresAt: Date(timeIntervalSinceNow: 72000), isViewed: false),
        Story(id: "story-creator", author: creator, expiresAt: Date(timeIntervalSinceNow: 65000), isViewed: false),
        Story(id: "story-editor", author: editor, expiresAt: Date(timeIntervalSinceNow: 48000), isViewed: true)
    ]

    public static let chats: [ChatSummary] = [
        ChatSummary(
            id: "chat-1",
            kind: .direct,
            title: "Марк Лебедев",
            lastMessage: "Отправил новый набросок эфира.",
            lastActivityAt: Date(timeIntervalSinceNow: -320),
            unreadCount: 3,
            isPinned: true,
            isEncrypted: true,
            avatarSymbol: "M"
        ),
        ChatSummary(
            id: "chat-2",
            kind: .group,
            title: "Команда Unio",
            lastMessage: "Лера: нужно проверить поток авторизации.",
            lastActivityAt: Date(timeIntervalSinceNow: -1200),
            unreadCount: 12,
            isPinned: true,
            isEncrypted: false,
            avatarSymbol: "U"
        ),
        ChatSummary(
            id: "chat-3",
            kind: .channel,
            title: "Unio Updates",
            lastMessage: "Новый билд готов к внутреннему тесту.",
            lastActivityAt: Date(timeIntervalSinceNow: -7200),
            unreadCount: 0,
            isPinned: false,
            isEncrypted: false,
            avatarSymbol: "↗"
        )
    ]

    public static let messages: [Message] = [
        Message(
            id: "message-1",
            chatID: "chat-1",
            author: creator,
            text: "Проверил идею с плавающим баром. В монохроме она выглядит намного тише.",
            kind: .text,
            attachments: [],
            createdAt: Date(timeIntervalSinceNow: -900),
            isOutgoing: false,
            isEdited: false
        ),
        Message(
            id: "message-2",
            chatID: "chat-1",
            author: currentUser,
            text: "Да, оставим стекло только на навигации. Контенту нужен воздух и читаемость.",
            kind: .text,
            attachments: [],
            createdAt: Date(timeIntervalSinceNow: -620),
            isOutgoing: true,
            isEdited: true
        ),
        Message(
            id: "message-3",
            chatID: "chat-1",
            author: creator,
            text: "Записал голосовую с пояснением.",
            kind: .voice,
            attachments: [
                MediaAttachment(id: "voice-1", kind: .voiceNote, title: "Голосовое сообщение", subtitle: "0:24", duration: 24)
            ],
            createdAt: Date(timeIntervalSinceNow: -300),
            isOutgoing: false,
            isEdited: false
        )
    ]

    public static let aiConversation = AIConversation(
        id: "ai-1",
        title: "Unio AI",
        messages: [
            AIMessage(role: .assistant, text: "Я помогу написать пост, перевести сообщение или подготовить ответ в чате."),
            AIMessage(role: .user, text: "Сделай короткий анонс нового эфира."),
            AIMessage(role: .assistant, text: "Сегодня в прямом эфире разберем, как строить спокойные цифровые сообщества без лишнего шума.")
        ]
    )
}
