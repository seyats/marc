import Foundation

public enum AppTab: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case home
    case chats
    case profile

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .home: "Главная"
        case .chats: "Чаты"
        case .profile: "Профиль"
        }
    }

    public var systemImage: String {
        switch self {
        case .home: "house"
        case .chats: "bubble.left.and.bubble.right"
        case .profile: "person.crop.circle"
        }
    }

    public var filledSystemImage: String {
        switch self {
        case .home: "house.fill"
        case .chats: "bubble.left.and.bubble.right.fill"
        case .profile: "person.crop.circle.fill"
        }
    }
}
