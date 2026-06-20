import AppCore
import DesignSystem
import SwiftUI

public struct HomeView: View {
    private enum FeedScope: String, CaseIterable {
        case recommended = "Рекомендации"
        case following = "Подписки"
    }

    private let stories: [Story]
    private let onRoute: (Route) -> Void
    private let onSheet: (SheetDestination) -> Void
    @State private var selectedScope: FeedScope = .recommended
    @State private var posts: [Post]
    @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(\.unioPalette) private var palette

    public init(
        posts: [Post] = Fixtures.posts,
        stories: [Story] = Fixtures.stories,
        onRoute: @escaping (Route) -> Void,
        onSheet: @escaping (SheetDestination) -> Void
    ) {
        self._posts = State(initialValue: posts)
        self.stories = stories
        self.onRoute = onRoute
        self.onSheet = onSheet
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            palette.background.ignoresSafeArea()
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: []) {
                    header
                    StoryStrip(stories: stories) { story in
                        onSheet(.storyViewer(storyID: story.id))
                    }
                    scopePicker
                    trends
                    ForEach(posts) { post in
                        PostCard(post: post) { route in
                            onRoute(route)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                    skeletonFooter
                        .padding(.horizontal, 16)
                        .padding(.bottom, 96)
                }
            }
            VStack(spacing: 12) {
                FloatingGlassButton(systemImage: "sparkles", accessibilityLabel: "Открыть Unio AI") {
                    onSheet(.aiAssistant)
                }
                FloatingGlassButton(systemImage: "square.and.pencil", accessibilityLabel: "Создать публикацию") {
                    onSheet(.composer)
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 92)
        }
        .navigationBarHidden(true)
        .task(id: selectedScope) {
            await refreshFeed()
        }
    }

    @MainActor
    private func refreshFeed() async {
        do {
            let page = try await appEnvironment.feedService.loadFeed(cursor: nil, followingOnly: selectedScope == .following)
            posts = page.posts
        } catch {
            if posts.isEmpty {
                posts = Fixtures.posts
            }
        }
    }

    private var header: some View {
        UnioTopBar(title: "Главная") {
            Button {
                onRoute(.search(query: nil))
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.glass)
            .accessibilityLabel("Поиск")

            Button {
                onSheet(.liveRoom(liveID: "live-main"))
            } label: {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.glass)
            .accessibilityLabel("Unio Live")
        }
        .padding(.bottom, 10)
    }

    private var scopePicker: some View {
        HStack(spacing: 6) {
            ForEach(FeedScope.allCases, id: \.self) { scope in
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.76)) {
                        selectedScope = scope
                    }
                } label: {
                    Text(scope.rawValue)
                        .font(.system(.callout, design: .default, weight: .semibold))
                        .foregroundStyle(selectedScope == scope ? palette.inverseText : palette.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(
                            Capsule()
                                .fill(selectedScope == scope ? palette.inverseSurface : palette.surface)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    private var trends: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["#Unio", "#дизайн", "#сообщество", "#эфир", "#AI"], id: \.self) { tag in
                    Text(tag)
                        .font(UnioTypography.callout)
                        .foregroundStyle(palette.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(palette.surface))
                        .overlay(Capsule().stroke(palette.separator, lineWidth: 0.7))
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 12)
    }

    private var skeletonFooter: some View {
        VStack(spacing: 10) {
            SkeletonBlock(height: 18)
            SkeletonBlock(height: 120)
        }
        .padding(.top, 8)
    }
}

private struct StoryStrip: View {
    let stories: [Story]
    let onTap: (Story) -> Void
    @Environment(\.unioPalette) private var palette

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                ForEach(stories) { story in
                    Button {
                        onTap(story)
                    } label: {
                        VStack(spacing: 8) {
                            AvatarView(symbol: story.author.avatarSymbol, size: 62, isStoryActive: true, isViewed: story.isViewed)
                            Text(story.author.displayName.components(separatedBy: " ").first ?? story.author.displayName)
                                .font(UnioTypography.caption)
                                .foregroundStyle(palette.textPrimary)
                        }
                        .frame(width: 76)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

private struct PostCard: View {
    @State private var post: Post
    let onRoute: (Route) -> Void
    @Environment(\.unioPalette) private var palette

    init(post: Post, onRoute: @escaping (Route) -> Void) {
        self._post = State(initialValue: post)
        self.onRoute = onRoute
    }

    var body: some View {
        MonochromeCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 10) {
                    Button {
                        onRoute(.profile(userID: post.author.id))
                    } label: {
                        AvatarView(symbol: post.author.avatarSymbol)
                    }
                    .buttonStyle(.plain)
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 5) {
                            Text(post.author.displayName)
                                .font(.system(.callout, design: .default, weight: .semibold))
                            if post.author.isVerified { VerifiedBadge() }
                        }
                        Text(post.author.username)
                            .font(UnioTypography.caption)
                            .foregroundStyle(palette.textSecondary)
                    }
                    Spacer()
                    Button {
                        UnioHaptics.light()
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(palette.textPrimary)
                            .frame(width: 42, height: 30)
                            .background(Capsule().fill(palette.surface))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Дополнительные действия")
                }

                Button {
                    onRoute(.postDetail(postID: post.id))
                } label: {
                    Text(post.text)
                        .font(UnioTypography.body)
                        .foregroundStyle(palette.textPrimary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)

                ForEach(post.attachments) { attachment in
                    MediaPreview(attachment: attachment)
                }

                HStack {
                    Text(UnioFormatters.relativeTime(post.createdAt))
                    Text("·")
                    Text("\(UnioFormatters.compactCount(post.viewCount)) просмотров")
                }
                .font(UnioTypography.caption)
                .foregroundStyle(palette.textSecondary)

                HStack {
                    IconActionButton(systemImage: "bubble.left", filledSystemImage: "bubble.left.fill", title: "Ответить", count: post.replyCount) {}
                    Spacer()
                    IconActionButton(systemImage: "arrow.2.squarepath", filledSystemImage: "arrow.2.squarepath", title: "Репост", count: post.repostCount) {}
                    Spacer()
                    IconActionButton(systemImage: "heart", filledSystemImage: "heart.fill", title: "Нравится", count: post.likeCount, isActive: post.isLiked) {
                        post.isLiked.toggle()
                        post.likeCount += post.isLiked ? 1 : -1
                        UnioHaptics.light()
                    }
                    Spacer()
                    IconActionButton(systemImage: "bookmark", filledSystemImage: "bookmark.fill", title: "Сохранить", isActive: post.isBookmarked) {
                        post.isBookmarked.toggle()
                        UnioHaptics.light()
                    }
                    Spacer()
                    IconActionButton(systemImage: "square.and.arrow.up", filledSystemImage: "square.and.arrow.up.fill", title: "Поделиться") {}
                }
            }
        }
    }
}

private struct MediaPreview: View {
    let attachment: MediaAttachment
    @Environment(\.unioPalette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .semibold))
                VStack(alignment: .leading, spacing: 3) {
                    Text(attachment.title)
                        .font(.system(.callout, design: .default, weight: .semibold))
                    Text(attachment.subtitle)
                        .font(UnioTypography.caption)
                        .foregroundStyle(palette.textSecondary)
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: UnioRadius.md, style: .continuous)
                    .fill(palette.raisedSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: UnioRadius.md, style: .continuous)
                    .stroke(palette.separator, lineWidth: 0.7)
            )
        }
    }

    private var icon: String {
        switch attachment.kind {
        case .image: "photo"
        case .video: "play.rectangle"
        case .linkPreview: "link"
        case .voiceNote: "waveform"
        case .file: "doc"
        }
    }
}

public struct ComposerView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.unioPalette) private var palette
    @State private var text: String
    @State private var isPublishing = false
    @State private var errorMessage: String?

    public init(initialText: String? = nil) {
        self._text = State(initialValue: initialText ?? DraftHandoffStorage.consume() ?? "")
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: UnioSpacing.md) {
                TextEditor(text: $text)
                    .font(UnioTypography.body)
                    .scrollContentBackground(.hidden)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: UnioRadius.md).fill(palette.surface))
                    .overlay(RoundedRectangle(cornerRadius: UnioRadius.md).stroke(palette.separator, lineWidth: 0.7))
                    .frame(minHeight: 220)
                if let errorMessage {
                    Text(errorMessage)
                        .font(UnioTypography.caption)
                        .foregroundStyle(palette.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack {
                    Label("Фото", systemImage: "photo")
                    Spacer()
                    Label("Видео", systemImage: "play.rectangle")
                    Spacer()
                    Label("Голос", systemImage: "waveform")
                }
                .font(UnioTypography.callout)
                .foregroundStyle(palette.textSecondary)
                Spacer()
            }
            .padding()
            .background(palette.background.ignoresSafeArea())
            .navigationTitle("Новая публикация")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Опубликовать") {
                        Task { await publishDraft() }
                    }
                    .fontWeight(.bold)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPublishing)
                }
            }
        }
    }

    @MainActor
    private func publishDraft() async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isPublishing = true
        errorMessage = nil
        do {
            _ = try await appEnvironment.feedService.publish(DraftPost(text: trimmed))
            UnioHaptics.success()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isPublishing = false
    }
}

public struct PostDetailView: View {
    private let postID: String
    @Environment(\.unioPalette) private var palette

    public init(postID: String) {
        self.postID = postID
    }

    public var body: some View {
        ScrollView {
            PostCard(post: Fixtures.posts.first { $0.id == postID } ?? Fixtures.posts[0]) { _ in }
                .padding()
        }
        .background(palette.background.ignoresSafeArea())
        .navigationTitle("Публикация")
    }
}

public struct SearchView: View {
    @State private var query: String
    @Environment(\.unioPalette) private var palette

    public init(query: String? = nil) {
        self._query = State(initialValue: query ?? "")
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: UnioSpacing.md) {
            TextField("Посты, люди и темы", text: $query)
                .textInputAutocapitalization(.never)
                .padding()
                .background(RoundedRectangle(cornerRadius: UnioRadius.md).fill(palette.surface))
            Text("Тренды")
                .font(UnioTypography.section)
            ForEach(["#Unio", "#дизайн", "#сообщество"], id: \.self) { tag in
                MonochromeCard {
                    HStack {
                        Text(tag).font(UnioTypography.callout)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(palette.textSecondary)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(palette.background.ignoresSafeArea())
        .navigationTitle("Поиск")
    }
}

public struct StoryViewerView: View {
    private let storyID: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.unioPalette) private var palette

    public init(storyID: String) {
        self.storyID = storyID
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            palette.inverseSurface.ignoresSafeArea()
            VStack(spacing: UnioSpacing.lg) {
                Capsule()
                    .fill(palette.inverseText)
                    .frame(height: 4)
                    .padding(.top, 20)
                Spacer()
                Text("История")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(palette.inverseText)
                Text(storyID)
                    .foregroundStyle(palette.inverseText.opacity(0.66))
                Spacer()
            }
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(palette.inverseText)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.glass)
            .padding()
        }
    }
}

public struct LiveRoomView: View {
    private let liveID: String
    @Environment(\.unioPalette) private var palette

    public init(liveID: String) {
        self.liveID = liveID
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            palette.inverseSurface.ignoresSafeArea()
            VStack {
                Text("Unio Live")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(palette.inverseText)
                Text(liveID)
                    .foregroundStyle(palette.inverseText.opacity(0.64))
            }
            GlassSurface(cornerRadius: 24, isInteractive: true) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Онлайн-чат")
                        .font(UnioTypography.callout)
                    Text("Лера: эфир уже начался")
                    Text("Марк: отправил реакцию")
                }
                .foregroundStyle(palette.textPrimary)
                .padding()
            }
            .padding()
        }
    }
}

public struct MediaViewerView: View {
    private let mediaID: String
    @Environment(\.unioPalette) private var palette

    public init(mediaID: String) {
        self.mediaID = mediaID
    }

    public var body: some View {
        VStack(spacing: UnioSpacing.md) {
            Image(systemName: "photo")
                .font(.system(size: 72))
            Text("Медиа \(mediaID)")
                .font(UnioTypography.section)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.background.ignoresSafeArea())
    }
}
