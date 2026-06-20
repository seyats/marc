import AIHubFeature
import AppCore
import AuthFeature
import ChatsFeature
import DesignSystem
import HomeFeature
import Infrastructure
import IntentsFeature
import ProfileFeature
import SwiftUI

@main
@MainActor
struct UnioApp: App {
    @State private var environment = ServiceFactory.makeProductionEnvironment()
    @State private var router = AppRouter()
    @State private var themeMode: ThemeMode = .light

    var body: some Scene {
        WindowGroup {
            RootView(themeMode: $themeMode)
                .environment(environment)
                .environment(router)
                .unioTheme(themeMode)
                .onContinueUserActivity(UnioIntentHandoffActivity.activityType) { _ in
                    if let handoff = IntentHandoffStorage.consume() {
                        router.apply(handoff)
                    }
                }
        }
    }
}
