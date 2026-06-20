import AppCore
import DesignSystem
import SwiftUI

public struct ChatsView: View {
    @State private var chats: [ChatSummary]
    private let onRoute: (Route) -> Void
    private let onSheet: (SheetDestination) -> Void
    @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(\.unioPalette) private var palette

    public init(
        chats: [ChatSummary] = Fixtures.chats,
        onRoute: @escaping (Route) -> Void,
        onSheet: @escaping (SheetDestination) -> Void
    ) {
        self._chats = State(initialValue: chats)
        self.onRoute = onRoute
        self.onSheet = onSheet
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            palette.background.ignoresSafeArea()
            ScrollView {
                LazyVStack(spacing: 10) {
                    UnioTopBar(title: "Чаты") {
                        Button {
                            onRoute(.search(query: nil))
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(palette.textPrimary)
                                .frame(width: 36, height: 36)
                        }
                        .buttonStyle(.glass)
                    }
                    .padding(.bottom, 6)

                    ForEach(chats) { chat in
                        ChatRow(chat: chat) {
                            onRoute(.chatThread(chatID: chat.id))
                        }
                        .padding(.horizontal, 16)
                    }
                    VStack(spacing: 10) {
                        SkeletonBlock(height: 54)
                        SkeletonBlock(height: 54)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 96)
                }
            }
            FloatingGlassButton(systemImage: "square.and.pencil", accessibilityLabel: "Новый чат") {
                onSheet(.attachmentPicker(chatID: nil))
            }
            .padding(.trailing, 20)
            .padding(.bottom, 92)
        }
        .navigationBarHidden(true)
        .task {
            await refreshChats()
        }
    }

    @MainActor
    private func refreshChats() async {
        do {
            let page = try await appEnvironment.chatService.loadChats(cursor: nil)
            chats = page.chats
        } catch {
            chats = Fixtures.chats
        }
    }
}

private struct ChatRow: View {
    let chat: ChatSummary
    let action: () -> Void
    @Environment(\.unioPalette) private var palette

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                AvatarView(symbol: chat.avatarSymbol, size: 52)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        if chat.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 11))
                        }
                        Text(chat.title)
                            .font(.system(.callout, design: .default, weight: .semibold))
                        if chat.isEncrypted {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10, weight: .semibold))
                        }
                    }
                    Text(chat.lastMessage)
                        .font(UnioTypography.caption)
                        .foregroundStyle(palette.textSecondary)
                        .lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 7) {
                    Text(UnioFormatters.relativeTime(chat.lastActivityAt))
                        .font(UnioTypography.caption)
                        .foregroundStyle(palette.textSecondary)
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(palette.inverseText)
                            .frame(minWidth: 22, minHeight: 22)
                            .background(Circle().fill(palette.inverseSurface))
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: UnioRadius.md, style: .continuous)
                    .fill(palette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: UnioRadius.md, style: .continuous)
                    .stroke(chat.isPinned ? palette.textPrimary.opacity(0.55) : palette.separator, lineWidth: chat.isPinned ? 1 : 0.6)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(chat.title)
    }
}

public struct ChatThreadView: View {
    private let chatID: String
    private let onSheet: (SheetDestination) -> Void
    @State private var draft = ""
    @State private var messages: [Message]
    @State private var knownMessageIDs: Set<String>
    @State private var chatTitle: String
    @State private var loadError: String?
    @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(\.unioPalette) private var palette

    public init(chatID: String, messages: [Message] = Fixtures.messages, onSheet: @escaping (SheetDestination) -> Void) {
        self.chatID = chatID
        self.onSheet = onSheet
        let initialMessages = messages.filter { $0.chatID == chatID }
        let fallbackMessages = Fixtures.messages.filter { $0.chatID == chatID }
        let resolvedMessages = initialMessages.isEmpty ? fallbackMessages : initialMessages
        self._messages = State(initialValue: resolvedMessages)
        self._knownMessageIDs = State(initialValue: Set(resolvedMessages.map(\.id)))
        self._chatTitle = State(initialValue: Fixtures.chats.first { $0.id == chatID }?.title ?? "Чат")
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            palette.background.ignoresSafeArea()
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        if let loadError {
                            Text(loadError)
                                .font(UnioTypography.caption)
                                .foregroundStyle(palette.textSecondary)
                                .padding(.horizontal, 14)
                        }
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .padding(.horizontal, 14)
                                .id(message.id)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 92)
                }
                .onChange(of: messages.last?.id) { _, newValue in
                    guard let newValue else { return }
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                        proxy.scrollTo(newValue, anchor: .bottom)
                    }
                }
                .task {
                    if let last = messages.last?.id {
                        proxy.scrollTo(last, anchor: .bottom)
                    }
                }
            }
            composer
        }
        .navigationTitle(title)
        .task(id: chatID) {
            await loadThread()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    UnioHaptics.medium()
                } label: {
                    Image(systemName: "phone")
                }
                Button {
                    UnioHaptics.medium()
                } label: {
                    Image(systemName: "video")
                }
            }
        }
    }

    private var title: String {
        chatTitle
    }

    private var composer: some View {
        GlassSurface(cornerRadius: 26, isInteractive: true) {
            HStack(spacing: 10) {
                Button {
                    onSheet(.attachmentPicker(chatID: chatID))
                } label: {
                    Image(systemName: "paperclip")
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.plain)
                TextField("Сообщение", text: $draft, axis: .vertical)
                    .lineLimit(1...4)
                Button {
                    Task { await sendMessage() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28, weight: .bold))
                }
                .buttonStyle(.plain)
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .foregroundStyle(palette.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }

    @MainActor
    private func loadThread() async {
        loadError = nil
        do {
            let chatsPage = try await appEnvironment.chatService.loadChats(cursor: nil)
            if let summary = chatsPage.chats.first(where: { $0.id == chatID }) {
                chatTitle = summary.title
            }
            let page = try await appEnvironment.chatService.loadMessages(chatID: chatID, cursor: nil)
            replaceMessages(with: page.messages)
            let stream = try await appEnvironment.realtimeService.subscribeToChat(chatID)
            for await message in stream {
                appendMessage(message)
            }
        } catch {
            loadError = error.localizedDescription
        }
    }

    @MainActor
    private func sendMessage() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        do {
            let message = try await appEnvironment.chatService.sendMessage(chatID: chatID, text: text, attachments: [])
            appendMessage(message)
            draft = ""
            UnioHaptics.medium()
        } catch {
            loadError = error.localizedDescription
        }
    }

    @MainActor
    private func replaceMessages(with newMessages: [Message]) {
        var seen = Set<String>()
        messages = newMessages.filter { seen.insert($0.id).inserted }.sorted { $0.createdAt < $1.createdAt }
        knownMessageIDs = Set(messages.map(\.id))
    }

    @MainActor
    private func appendMessage(_ message: Message) {
        guard knownMessageIDs.insert(message.id).inserted else { return }
        messages.append(message)
        messages.sort { $0.createdAt < $1.createdAt }
    }
}

private struct MessageBubble: View {
    let message: Message
    @Environment(\.unioPalette) private var palette

    var body: some View {
        HStack {
            if message.isOutgoing { Spacer(minLength: 48) }
            VStack(alignment: .leading, spacing: 7) {
                if message.kind == .voice {
                    HStack(spacing: 3) {
                        ForEach(0..<18, id: \.self) { index in
                            Capsule()
                                .fill(message.isOutgoing ? palette.inverseText.opacity(0.72) : palette.textPrimary.opacity(0.72))
                                .frame(width: 3, height: CGFloat(8 + (index % 5) * 5))
                        }
                    }
                    Text("Голосовое сообщение")
                        .font(UnioTypography.caption)
                        .foregroundStyle(message.isOutgoing ? palette.inverseText.opacity(0.7) : palette.textSecondary)
                } else {
                    Text(message.text)
                        .font(UnioTypography.body)
                }
                HStack(spacing: 4) {
                    Text(UnioFormatters.relativeTime(message.createdAt))
                    if message.isEdited { Text("изменено") }
                }
                .font(UnioTypography.caption)
                .foregroundStyle(message.isOutgoing ? palette.inverseText.opacity(0.7) : palette.textSecondary)
            }
            .foregroundStyle(message.isOutgoing ? palette.inverseText : palette.textPrimary)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(message.isOutgoing ? palette.inverseSurface : palette.surface)
            )
            if !message.isOutgoing { Spacer(minLength: 48) }
        }
    }
}

public struct AttachmentPickerView: View {
    private let chatID: String?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.unioPalette) private var palette

    public init(chatID: String?) {
        self.chatID = chatID
    }

    public var body: some View {
        VStack(spacing: UnioSpacing.md) {
            Capsule()
                .fill(palette.separator)
                .frame(width: 44, height: 5)
                .padding(.top, 8)
            Text(chatID == nil ? "Новый чат" : "Вложение")
                .font(UnioTypography.section)
            ForEach([
                ("Фото или видео", "photo.on.rectangle"),
                ("Файл", "doc"),
                ("Голосовое", "waveform"),
                ("Контакт", "person.crop.circle")
            ], id: \.0) { item in
                MonochromeCard {
                    HStack {
                        Image(systemName: item.1)
                            .frame(width: 32)
                        Text(item.0)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(palette.textSecondary)
                    }
                }
            }
            Button("Готово") { dismiss() }
                .buttonStyle(PrimaryMonochromeButtonStyle())
            Spacer()
        }
        .padding()
        .background(palette.background.ignoresSafeArea())
    }
}
