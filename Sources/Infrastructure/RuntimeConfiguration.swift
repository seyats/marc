import AppCore
import Foundation

public struct AppRuntimeConfiguration: Sendable {
    public var apiBaseURL: URL
    public var websocketURL: URL
    public var aiBaseURL: URL
    public var firebaseProjectID: String

    public init(apiBaseURL: URL, websocketURL: URL, aiBaseURL: URL, firebaseProjectID: String) {
        self.apiBaseURL = apiBaseURL
        self.websocketURL = websocketURL
        self.aiBaseURL = aiBaseURL
        self.firebaseProjectID = firebaseProjectID
    }

    public static let placeholder = AppRuntimeConfiguration(
        apiBaseURL: URL(string: "https://api.example.unio.app")!,
        websocketURL: URL(string: "wss://realtime.example.unio.app")!,
        aiBaseURL: URL(string: "https://ai.example.unio.app")!,
        firebaseProjectID: "replace-with-production-project-id"
    )
}

@MainActor
public enum ServiceFactory {
    public static func makePreviewEnvironment() -> AppEnvironment {
        AppEnvironment(
            authService: PreviewAuthService(),
            feedService: PreviewFeedService(),
            chatService: PreviewChatService(),
            realtimeService: PreviewRealtimeService(),
            mediaService: PreviewMediaService(),
            notificationService: PreviewNotificationService(),
            localStore: PreviewLocalStore(),
            aiService: PreviewAIService()
        )
    }

    public static func makeProductionEnvironment(configuration: AppRuntimeConfiguration = .placeholder) -> AppEnvironment {
        let supabaseConfiguration = SupabaseRuntimeConfiguration.fromEnvironment()
        let authService = SupabaseAuthAdapter(configuration: supabaseConfiguration)
        let currentUser: @Sendable () async -> UserProfile = {
            if case let .signedIn(profile) = await authService.currentState() {
                return profile
            }
            return Fixtures.currentUser
        }
        let feedService = SupabaseFeedAdapter(configuration: supabaseConfiguration, currentUser: currentUser)
        let chatService = SupabaseChatAdapter(configuration: supabaseConfiguration, currentUser: currentUser)
        return AppEnvironment(
            authService: authService,
            feedService: feedService,
            chatService: chatService,
            realtimeService: SupabaseRealtimeAdapter(configuration: supabaseConfiguration),
            mediaService: SupabaseMediaAdapter(configuration: supabaseConfiguration),
            notificationService: SupabaseNotificationAdapter(configuration: supabaseConfiguration),
            localStore: GRDBLocalStoreAdapter(),
            aiService: BackendAIAdapter(configuration: configuration)
        )
    }
}
