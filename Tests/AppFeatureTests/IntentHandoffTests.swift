import AppCore
import IntentsFeature
import XCTest

final class IntentHandoffTests: XCTestCase {
    func testComposeIntentWritesDraftHandoff() async throws {
        _ = try await ComposeUnioPostIntent(text: "Текст из Shortcut").perform()

        XCTAssertEqual(IntentHandoffStorage.consume(), .composeDraft(text: "Текст из Shortcut"))
    }

    func testOpenTabIntentWritesTabHandoff() async throws {
        _ = try await OpenUnioTabIntent(tab: .chats).perform()

        XCTAssertEqual(IntentHandoffStorage.consume(), .openTab(.chats))
    }
}
