import AppCore
import DesignSystem
import SwiftUI

public struct ProfileView: View {
    private let user: UserProfile
    private let onRoute: (Route) -> Void
    private let onSheet: (SheetDestination) -> Void
    @Environment(\.unioPalette) private var palette

    public init(
        user: UserProfile = Fixtures.currentUser,
        onRoute: @escaping (Route) -> Void,
        onSheet: @escaping (SheetDestination) -> Void
    ) {
        self.user = user
        self.onRoute = onRoute
        self.onSheet = onSheet
    }

    public var body: some View {
        ZStack {
            palette.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    cover
                    menu
                    profileFeed
                        .padding(.bottom, 108)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var cover: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [.black, Color(white: 0.18), Color(white: 0.04)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(GeometricTexture().opacity(0.18))
            .frame(height: 310)

            HStack {
                Button {
                    UnioHaptics.light()
                } label: {
                    Image(systemName: "qrcode")
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.glass)
                Spacer()
                Button("Изменить") {
                    onSheet(.editProfile)
                }
                .font(.system(.callout, design: .default, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .buttonStyle(.glass)
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)

            VStack(spacing: 9) {
                Spacer()
                AvatarView(symbol: user.avatarSymbol, size: 112)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
                HStack(spacing: 6) {
                    Text(user.displayName)
                        .font(.system(.title2, design: .default, weight: .bold))
                        .foregroundStyle(.white)
                    if user.isVerified { VerifiedBadge() }
                }
                Text("\(user.phoneOrStatus) · \(user.username)")
                    .font(UnioTypography.callout)
                    .foregroundStyle(Color(white: 0.78))
                HStack(spacing: 24) {
                    stat(title: "подписчиков", value: user.followersCount)
                    stat(title: "подписок", value: user.followingCount)
                }
                .padding(.top, 6)
                Spacer().frame(height: 20)
            }
        }
    }

    private func stat(title: String, value: Int) -> some View {
        VStack(spacing: 2) {
            Text(UnioFormatters.compactCount(value))
                .font(.system(.callout, design: .default, weight: .bold))
                .foregroundStyle(.white)
            Text(title)
                .font(UnioTypography.caption)
                .foregroundStyle(Color(white: 0.74))
        }
    }

    private var menu: some View {
        VStack(spacing: 10) {
            ForEach(ProfileMenuItem.primary) { item in
                ProfileMenuRow(item: item) {
                    switch item.route {
                    case .settings: onRoute(.settings)
                    case .security: onRoute(.security)
                    case .privacy: onRoute(.privacy)
                    case .none: UnioHaptics.light()
                    }
                }
            }
        }
        .padding(16)
    }

    private var profileFeed: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Публикации")
                .font(UnioTypography.section)
                .padding(.horizontal, 16)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(Fixtures.posts) { post in
                    Button {
                        onRoute(.postDetail(postID: post.id))
                    } label: {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(palette.surface)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                Image(systemName: post.attachments.first?.kind == .linkPreview ? "link" : "text.alignleft")
                                    .foregroundStyle(palette.textSecondary)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct GeometricTexture: View {
    var body: some View {
        Canvas { context, size in
            let path = Path { path in
                let step: CGFloat = 32
                var x: CGFloat = 0
                while x < size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x + size.height, y: size.height))
                    x += step
                }
            }
            context.stroke(path, with: .color(.white), lineWidth: 0.6)
        }
    }
}

private struct ProfileMenuItem: Identifiable {
    enum Destination {
        case settings
        case security
        case privacy
    }

    let id = UUID()
    let title: String
    let systemImage: String
    let route: Destination?

    static let primary: [ProfileMenuItem] = [
        ProfileMenuItem(title: "Мой профиль", systemImage: "person.crop.circle", route: nil),
        ProfileMenuItem(title: "Сохранённые сообщения", systemImage: "bookmark", route: nil),
        ProfileMenuItem(title: "Последние звонки", systemImage: "phone", route: nil),
        ProfileMenuItem(title: "Устройства", systemImage: "desktopcomputer", route: .security),
        ProfileMenuItem(title: "Папки чатов", systemImage: "folder", route: .settings),
        ProfileMenuItem(title: "Уведомления и звуки", systemImage: "bell", route: .settings),
        ProfileMenuItem(title: "Конфиденциальность", systemImage: "hand.raised", route: .privacy),
        ProfileMenuItem(title: "Безопасность", systemImage: "lock", route: .security)
    ]
}

private struct ProfileMenuRow: View {
    let item: ProfileMenuItem
    let action: () -> Void
    @Environment(\.unioPalette) private var palette

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: item.systemImage)
                    .foregroundStyle(palette.inverseText)
                    .frame(width: 34, height: 34)
                    .background(RoundedRectangle(cornerRadius: 9).fill(palette.inverseSurface.opacity(0.9)))
                Text(item.title)
                    .font(UnioTypography.callout)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(palette.textSecondary)
            }
            .foregroundStyle(palette.textPrimary)
        }
        .buttonStyle(.plain)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: UnioRadius.md).fill(palette.surface))
    }
}

public struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.unioPalette) private var palette
    @State private var firstName = "Анна"
    @State private var lastName = "Волкова"
    @State private var bio = Fixtures.currentUser.bio

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: UnioSpacing.md) {
                    AvatarView(symbol: "A", size: 112)
                        .overlay {
                            Circle()
                                .fill(.black.opacity(0.18))
                            Image(systemName: "camera.fill")
                                .foregroundStyle(.white)
                        }
                    Button("Выбрать фотографию") {}
                        .foregroundStyle(palette.textPrimary)
                        .underline()

                    inputGroup {
                        TextField("Имя", text: $firstName)
                        Divider()
                        TextField("Фамилия", text: $lastName)
                    }
                    Text("Имя и фото видны другим пользователям Unio.")
                        .font(UnioTypography.caption)
                        .foregroundStyle(palette.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    inputGroup {
                        TextField("О себе", text: $bio, axis: .vertical)
                            .lineLimit(3...6)
                    }
                    inputGroup {
                        row("Дата рождения", value: "Указать")
                    }
                    inputGroup {
                        row("Сменить номер", value: nil)
                        Divider()
                        row("Имя пользователя", value: Fixtures.currentUser.username)
                        Divider()
                        row("Персональные цвета", value: "Монохром")
                    }
                    Button("Добавить аккаунт") {}
                        .foregroundStyle(palette.textPrimary)
                    Button("Выйти") {}
                        .buttonStyle(SecondaryMonochromeButtonStyle())
                        .padding(.top, 16)
                }
                .padding()
            }
            .background(palette.background.ignoresSafeArea())
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                        .foregroundStyle(palette.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                        .fontWeight(.bold)
                }
            }
        }
    }

    private func inputGroup<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: UnioRadius.md).fill(palette.surface))
    }

    private func row(_ title: String, value: String?) -> some View {
        HStack {
            Text(title)
            Spacer()
            if let value {
                Text(value).foregroundStyle(palette.textSecondary)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(palette.textSecondary)
        }
    }
}

public struct SettingsView: View {
    @Environment(\.unioPalette) private var palette

    public init() {}

    public var body: some View {
        List {
            Section("Аккаунт") {
                Text("Папки чатов")
                Text("Уведомления и звуки")
                Text("Язык интерфейса: русский")
            }
            Section("Приложение") {
                Text("Тема: монохромная")
                Text("Liquid Glass: включено")
            }
        }
        .scrollContentBackground(.hidden)
        .background(palette.background)
        .navigationTitle("Настройки")
    }
}

public struct SecurityView: View {
    public init() {}

    public var body: some View {
        List {
            Section("Защита") {
                Label("Двухфакторная аутентификация", systemImage: "lock.shield")
                Label("Активные устройства", systemImage: "desktopcomputer")
                Label("Сквозное шифрование", systemImage: "lock")
            }
        }
        .navigationTitle("Безопасность")
    }
}

public struct PrivacyView: View {
    public init() {}

    public var body: some View {
        List {
            Section("Видимость") {
                Label("Номер телефона", systemImage: "phone")
                Label("Дата рождения", systemImage: "calendar")
                Label("Биография", systemImage: "text.alignleft")
            }
            Section("Модерация") {
                Label("Фильтр токсичности", systemImage: "checkmark.shield")
                Label("Спам-защита", systemImage: "hand.raised")
            }
        }
        .navigationTitle("Конфиденциальность")
    }
}
