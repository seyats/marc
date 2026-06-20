import AppCore
import Foundation

#if canImport(GRDB)
import GRDB
#endif

public actor WebSocketRealtimeAdapter: RealtimeService {
    private let configuration: AppRuntimeConfiguration
    private var isConnected = false

    public init(configuration: AppRuntimeConfiguration) {
        self.configuration = configuration
    }

    public func connect() async throws {
        guard configuration.websocketURL.host != "realtime.example.unio.app" else {
            throw UnioServiceError.unconfigured("WebSocket endpoint должен быть заменен на production URL.")
        }
        isConnected = true
    }

    public func disconnect() async {
        isConnected = false
    }

    public func subscribeToChat(_ chatID: String) async throws -> AsyncStream<Message> {
        AsyncStream { continuation in
            if !isConnected {
                continuation.finish()
            }
        }
    }
}

public actor GRDBLocalStoreAdapter: LocalStore {
    private var posts: [Post] = []
    private var chats: [ChatSummary] = []

    public init() {}

    public func savePosts(_ posts: [Post]) async throws {
        self.posts = posts
    }

    public func cachedPosts() async throws -> [Post] {
        posts.isEmpty ? Fixtures.posts : posts
    }

    public func saveChats(_ chats: [ChatSummary]) async throws {
        self.chats = chats
    }

    public func cachedChats() async throws -> [ChatSummary] {
        chats.isEmpty ? Fixtures.chats : chats
    }
}

public actor BackendAIAdapter: AIService {
    private let configuration: AppRuntimeConfiguration
    private let session: URLSession

    public init(configuration: AppRuntimeConfiguration, session: URLSession = .shared) {
        self.configuration = configuration
        self.session = session
    }

    public func respond(to message: String, context: AIContext) async throws -> AIMessage {
        guard configuration.aiBaseURL.host != "ai.example.unio.app" else {
            return AIMessage(role: .assistant, text: "AI backend пока не подключен. Текст принят: \(message)")
        }
        return AIMessage(role: .assistant, text: "Ответ будет получен от \(configuration.aiBaseURL.absoluteString).")
    }

    public func rewritePost(_ text: String) async throws -> String {
        guard !text.isEmpty else { throw UnioServiceError.validation("Введите текст для улучшения.") }
        return text
    }

    public func translateMessage(_ text: String, targetLanguage: String) async throws -> String {
        guard !targetLanguage.isEmpty else { throw UnioServiceError.validation("Укажите язык перевода.") }
        return text
    }
}
