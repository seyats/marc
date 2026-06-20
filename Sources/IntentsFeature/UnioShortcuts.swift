import AppIntents

public struct UnioIntentsPackage: AppIntentsPackage {
    public init() {}
}

public struct UnioShortcuts: AppShortcutsProvider {
    public static var shortcutTileColor: ShortcutTileColor { .gray }

    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenUnioTabIntent(tab: .home),
            phrases: [
                "Открой \(.applicationName)",
                "Открой главную в \(.applicationName)"
            ],
            shortTitle: "Открыть Unio",
            systemImageName: "house"
        )
        AppShortcut(
            intent: ComposeUnioPostIntent(),
            phrases: [
                "Создай публикацию в \(.applicationName)",
                "Напиши пост в \(.applicationName)"
            ],
            shortTitle: "Новая публикация",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: OpenUnioChatIntent(),
            phrases: [
                "Открой чат в \(.applicationName)"
            ],
            shortTitle: "Открыть чат",
            systemImageName: "bubble.left.and.bubble.right"
        )
        AppShortcut(
            intent: OpenUnioProfileIntent(),
            phrases: [
                "Открой профиль в \(.applicationName)"
            ],
            shortTitle: "Открыть профиль",
            systemImageName: "person.crop.circle"
        )
    }
}
