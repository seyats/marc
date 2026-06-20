import Foundation

public struct SupabaseRuntimeConfiguration: Sendable {
    public var supabaseURL: URL
    public var supabaseAnonKey: String
    public var storageBucket: String
    public var appGroupIdentifier: String
    public var postsTable: String
    public var chatsTable: String
    public var messagesTable: String
    public var profilesTable: String
    public var demoMode: Bool

    public init(
        supabaseURL: URL,
        supabaseAnonKey: String,
        storageBucket: String = "unio-media",
        appGroupIdentifier: String = "group.app.unio",
        postsTable: String = "posts",
        chatsTable: String = "chats",
        messagesTable: String = "messages",
        profilesTable: String = "profiles",
        demoMode: Bool = true
    ) {
        self.supabaseURL = supabaseURL
        self.supabaseAnonKey = supabaseAnonKey
        self.storageBucket = storageBucket
        self.appGroupIdentifier = appGroupIdentifier
        self.postsTable = postsTable
        self.chatsTable = chatsTable
        self.messagesTable = messagesTable
        self.profilesTable = profilesTable
        self.demoMode = demoMode
    }

    public static let placeholder = SupabaseRuntimeConfiguration(
        supabaseURL: URL(string: "https://example.supabase.co")!,
        supabaseAnonKey: "REPLACE_ME",
        demoMode: true
    )

    public static func fromEnvironment() -> SupabaseRuntimeConfiguration {
        let environment = ProcessInfo.processInfo.environment

        let urlString = environment["SUPABASE_URL"]
            ?? Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
            ?? placeholder.supabaseURL.absoluteString

        let anonKey = environment["SUPABASE_ANON_KEY"]
            ?? Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String
            ?? placeholder.supabaseAnonKey

        let storageBucket = environment["SUPABASE_STORAGE_BUCKET"]
            ?? Bundle.main.object(forInfoDictionaryKey: "SUPABASE_STORAGE_BUCKET") as? String
            ?? placeholder.storageBucket

        let appGroup = environment["UNIO_APP_GROUP"]
            ?? Bundle.main.object(forInfoDictionaryKey: "UNIO_APP_GROUP") as? String
            ?? placeholder.appGroupIdentifier

        let demoMode = environment["UNIO_DEMO_MODE"].map { $0 != "0" } ?? true

        return SupabaseRuntimeConfiguration(
            supabaseURL: URL(string: urlString) ?? placeholder.supabaseURL,
            supabaseAnonKey: anonKey,
            storageBucket: storageBucket,
            appGroupIdentifier: appGroup,
            demoMode: demoMode
        )
    }

    public var isConfigured: Bool {
        supabaseURL.host?.contains("example.supabase.co") == false && !supabaseAnonKey.contains("REPLACE_ME")
    }
}

public enum SupabaseDateCodec {
    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    public static func decode(_ string: String?) -> Date {
        guard let string else { return .now }
        return formatter.date(from: string) ?? .now
    }

    public static func encode(_ date: Date) -> String {
        formatter.string(from: date)
    }
}
