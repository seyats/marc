import AppCore
import XCTest

@MainActor
final class RoutingTests: XCTestCase {
    func testIntentHandoffOpensChatTabAndRoute() {
        let router = AppRouter()

        router.apply(.openChat(chatID: "chat-1"))

        XCTAssertEqual(router.selectedTab, .chats)
        XCTAssertEqual(router.chatsPath, [.chatThread(chatID: "chat-1")])
    }

    func testComposeDraftPresentsComposer() {
        let router = AppRouter()

        router.apply(.composeDraft(text: "Новый пост"))

        XCTAssertEqual(router.selectedTab, .home)
        XCTAssertEqual(router.presentedSheet, .composer)
        XCTAssertEqual(DraftHandoffStorage.consume(), "Новый пост")
    }
}
