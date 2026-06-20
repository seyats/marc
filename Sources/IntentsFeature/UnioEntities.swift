import AppCore
import AppIntents
import Foundation

public struct UnioChatEntity: AppEntity, Identifiable {
    public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Чат")
    public static let defaultQuery = UnioChatQuery()
    public static let defaultValue = UnioChatEntity(id: "chat-1", title: "Марк Лебедев")

    public let id: String
    public let title: String

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", subtitle: "Чат Unio")
    }
}

public struct UnioChatQuery: EntityQuery {
    public init() {}

    public func entities(for identifiers: [String]) async throws -> [UnioChatEntity] {
        suggested().filter { identifiers.contains($0.id) }
    }

    public func suggestedEntities() async throws -> [UnioChatEntity] {
        suggested()
    }

    private func suggested() -> [UnioChatEntity] {
        Fixtures.chats.map { UnioChatEntity(id: $0.id, title: $0.title) }
    }
}

public struct UnioProfileEntity: AppEntity, Identifiable {
    public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Профиль")
    public static let defaultQuery = UnioProfileQuery()
    public static let defaultValue = UnioProfileEntity(id: "user-current", title: "Анна Волкова")

    public let id: String
    public let title: String

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", subtitle: "Профиль Unio")
    }
}

public struct UnioProfileQuery: EntityQuery {
    public init() {}

    public func entities(for identifiers: [String]) async throws -> [UnioProfileEntity] {
        suggested().filter { identifiers.contains($0.id) }
    }

    public func suggestedEntities() async throws -> [UnioProfileEntity] {
        suggested()
    }

    private func suggested() -> [UnioProfileEntity] {
        [Fixtures.currentUser, Fixtures.creator, Fixtures.editor].map {
            UnioProfileEntity(id: $0.id, title: $0.displayName)
        }
    }
}
