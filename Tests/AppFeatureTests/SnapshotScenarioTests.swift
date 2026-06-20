import AIHubFeature
import AppCore
import AuthFeature
import ChatsFeature
import DesignSystem
import HomeFeature
import ProfileFeature
import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

@MainActor
final class SnapshotScenarioTests: XCTestCase {
    func testSnapshotCatalogIsReady() {
        XCTAssertEqual(SnapshotScenario.allCases.count, 6)
    }

    func testSnapshotsWhenEnabled() throws {
        guard ProcessInfo.processInfo.environment["UNIO_ENABLE_SNAPSHOTS"] == "1" else {
            throw XCTSkip("Set UNIO_ENABLE_SNAPSHOTS=1 on macOS Simulator CI to render visual snapshots.")
        }

        for scenario in SnapshotScenario.allCases {
            let controller = UIHostingController(rootView: scenario.view.unioTheme(.light))
            assertSnapshot(of: controller, as: .image(on: .iPhone13), named: "\(scenario.rawValue)-light")

            let darkController = UIHostingController(rootView: scenario.view.unioTheme(.dark))
            assertSnapshot(of: darkController, as: .image(on: .iPhone13), named: "\(scenario.rawValue)-dark")
        }
    }
}

private enum SnapshotScenario: String, CaseIterable {
    case auth
    case home
    case chats
    case thread
    case profile
    case ai

    @MainActor
    var view: AnyView {
        switch self {
        case .auth:
            AnyView(AuthFlowView {})
        case .home:
            AnyView(HomeView(onRoute: { _ in }, onSheet: { _ in }))
        case .chats:
            AnyView(ChatsView(onRoute: { _ in }, onSheet: { _ in }))
        case .thread:
            AnyView(ChatThreadView(chatID: "chat-1", onSheet: { _ in }))
        case .profile:
            AnyView(ProfileView(onRoute: { _ in }, onSheet: { _ in }))
        case .ai:
            AnyView(AIAssistantView())
        }
    }
}
