import AppCore
import DesignSystem
import SwiftUI

public struct AuthFlowView: View {
    private enum Step {
        case splash
        case onboarding
        case phone
        case code
        case profile
    }

    private let onAuthenticated: (UserProfile) -> Void
    @State private var step: Step = .splash
    @State private var onboardingPage = 0
    @State private var phone = ""
    @State private var code = ""
    @State private var displayName = ""
    @State private var username = ""
    @State private var enableBiometrics = true
    @State private var errorMessage: String?
    @State private var isWorking = false
    @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(\.unioPalette) private var palette

    public init(onAuthenticated: @escaping (UserProfile) -> Void) {
        self.onAuthenticated = onAuthenticated
    }

    public var body: some View {
        ZStack {
            palette.background.ignoresSafeArea()
            content
                .transition(.opacity.combined(with: .move(edge: .trailing)))
                .animation(.easeInOut(duration: 0.28), value: step)
        }
        .overlay(alignment: .bottom) {
            if let errorMessage {
                Text(errorMessage)
                    .font(UnioTypography.caption)
                    .foregroundStyle(palette.inverseText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(palette.inverseSurface))
                    .padding(.bottom, 20)
            }
        }
        .task {
            guard step == .splash else { return }
            try? await Task.sleep(for: .seconds(1.1))
            step = .onboarding
        }
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .splash:
            splash
        case .onboarding:
            onboarding
        case .phone:
            phoneEntry
        case .code:
            codeEntry
        case .profile:
            createProfile
        }
    }

    private var splash: some View {
        Text("Unio")
            .font(.system(size: 54, weight: .black, design: .default))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
            .scaleEffect(step == .splash ? 1 : 0.96)
            .accessibilityLabel("Unio")
    }

    private var onboarding: some View {
        VStack(spacing: UnioSpacing.lg) {
            Spacer()
            TabView(selection: $onboardingPage) {
                ForEach(OnboardingSlide.slides) { slide in
                    VStack(spacing: UnioSpacing.lg) {
                        MonochromeIllustration(systemImage: slide.systemImage)
                        VStack(spacing: UnioSpacing.sm) {
                            Text(slide.title)
                                .font(.system(.title, design: .default, weight: .bold))
                                .multilineTextAlignment(.center)
                            Text(slide.subtitle)
                                .font(UnioTypography.body)
                                .foregroundStyle(palette.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                    }
                    .tag(slide.index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 6) {
                ForEach(OnboardingSlide.slides) { slide in
                    Capsule()
                        .fill(onboardingPage == slide.index ? palette.textPrimary : palette.separator)
                        .frame(width: onboardingPage == slide.index ? 34 : 18, height: 4)
                        .animation(.spring(response: 0.28, dampingFraction: 0.8), value: onboardingPage)
                }
            }

            Button("Продолжить") {
                if onboardingPage < OnboardingSlide.slides.count - 1 {
                    onboardingPage += 1
                } else {
                    step = .phone
                }
            }
            .buttonStyle(PrimaryMonochromeButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
    }

    private var phoneEntry: some View {
        VStack(alignment: .leading, spacing: UnioSpacing.lg) {
            BackButton { step = .onboarding }
            Text("Ваш номер телефона")
                .font(.system(.largeTitle, design: .default, weight: .bold))
            Text("Мы отправим код подтверждения. Номер нужен для входа и защиты аккаунта.")
                .foregroundStyle(palette.textSecondary)
            GlassSurface(cornerRadius: 22, isInteractive: true) {
                HStack(spacing: UnioSpacing.sm) {
                    Text("RU +7")
                        .font(.system(.body, design: .default, weight: .semibold))
                    Divider().frame(height: 26)
                    TextField("Номер телефона", text: $phone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                }
                .padding()
            }
            Text("Нажимая продолжить, вы принимаете Условия использования и Политику конфиденциальности.")
                .font(UnioTypography.caption)
                .foregroundStyle(palette.textSecondary)
            socialAuth
            Spacer()
            Button("Продолжить") {
                Task { await startPhoneVerification() }
            }
            .buttonStyle(PrimaryMonochromeButtonStyle())
            .disabled(phone.filter(\.isNumber).count < 10 || isWorking)
            .opacity(phone.filter(\.isNumber).count < 10 || isWorking ? 0.46 : 1)
        }
        .padding(24)
    }

    private var socialAuth: some View {
        VStack(spacing: UnioSpacing.sm) {
            HStack(spacing: UnioSpacing.sm) {
                Rectangle()
                    .fill(palette.separator)
                    .frame(height: 1)
                Text("или")
                    .font(UnioTypography.caption)
                    .foregroundStyle(palette.textSecondary)
                Rectangle()
                    .fill(palette.separator)
                    .frame(height: 1)
            }
            HStack(spacing: UnioSpacing.sm) {
                ProviderAuthButton(provider: .apple, assetName: "AuthApple") {
                    Task { await signIn(with: .apple) }
                }
                ProviderAuthButton(provider: .google, assetName: "AuthGoogle") {
                    Task { await signIn(with: .google) }
                }
                ProviderAuthButton(provider: .github, assetName: "AuthGitHub") {
                    Task { await signIn(with: .github) }
                }
            }
        }
        .disabled(isWorking)
        .opacity(isWorking ? 0.66 : 1)
        .padding(.top, UnioSpacing.sm)
    }

    private var codeEntry: some View {
        VStack(alignment: .leading, spacing: UnioSpacing.lg) {
            BackButton { step = .phone }
            Text("Код подтверждения")
                .font(.system(.largeTitle, design: .default, weight: .bold))
            Text("Введите шесть цифр из сообщения.")
                .foregroundStyle(palette.textSecondary)
            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { index in
                    Text(character(at: index, in: code))
                        .font(.system(.title2, design: .monospaced, weight: .bold))
                        .frame(width: 44, height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(index == code.count ? palette.textPrimary : palette.separator, lineWidth: index == code.count ? 1.8 : 1)
                        )
                }
            }
            TextField("Код", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .frame(height: 1)
                .opacity(0.01)
            Text("Отправить ещё раз можно через 00:42")
                .font(UnioTypography.caption)
                .foregroundStyle(palette.textSecondary)
            Spacer()
            Button("Подтвердить") {
                Task { await confirmPhoneCode() }
            }
            .buttonStyle(PrimaryMonochromeButtonStyle())
            .disabled(code.count < 6 || isWorking)
            .opacity(code.count < 6 || isWorking ? 0.46 : 1)
        }
        .padding(24)
        .onChange(of: code) { _, newValue in
            code = String(newValue.filter(\.isNumber).prefix(6))
        }
    }

    private var createProfile: some View {
        VStack(spacing: UnioSpacing.lg) {
            Spacer()
            AvatarView(symbol: displayName.first.map { String($0) } ?? "U", size: 116)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(palette.inverseText)
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(palette.inverseSurface))
                }
            VStack(spacing: UnioSpacing.sm) {
                TextField("Имя", text: $displayName)
                    .textInputAutocapitalization(.words)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 18).fill(palette.surface))
                TextField("Юзернейм", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 18).fill(palette.surface))
            }
            MonochromeCard {
                Toggle("Вход по Face ID или Touch ID", isOn: $enableBiometrics)
                    .tint(palette.textPrimary)
            }
            Spacer()
            Button("Создать профиль") {
                let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
                let normalizedUsername: String
                if trimmedUsername.isEmpty {
                    normalizedUsername = "@unio"
                } else if trimmedUsername.hasPrefix("@") {
                    normalizedUsername = trimmedUsername
                } else {
                    normalizedUsername = "@\(trimmedUsername)"
                }
                onAuthenticated(
                    UserProfile(
                        id: UUID().uuidString,
                        displayName: trimmedDisplayName,
                        username: normalizedUsername,
                        phoneOrStatus: "В сети",
                        bio: "Новый пользователь Unio",
                        isVerified: false,
                        followersCount: 0,
                        followingCount: 0,
                        avatarSymbol: trimmedDisplayName.first.map { String($0) } ?? "U"
                    )
                )
            }
            .buttonStyle(PrimaryMonochromeButtonStyle())
            .disabled(displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.46 : 1)
        }
        .padding(24)
    }

    @MainActor
    private func startPhoneVerification() async {
        isWorking = true
        errorMessage = nil
        do {
            try await appEnvironment.authService.startPhoneVerification(phone: phone)
            step = .code
        } catch {
            errorMessage = error.localizedDescription
        }
        isWorking = false
    }

    @MainActor
    private func confirmPhoneCode() async {
        isWorking = true
        errorMessage = nil
        do {
            let profile = try await appEnvironment.authService.confirmCode(code)
            if shouldCollectProfileDetails(for: profile) {
                prefill(profile)
                step = .profile
            } else {
                onAuthenticated(profile)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isWorking = false
    }

    @MainActor
    private func signIn(with provider: AuthProvider) async {
        isWorking = true
        errorMessage = nil
        do {
            let profile = try await appEnvironment.authService.signIn(with: provider)
            if shouldCollectProfileDetails(for: profile) {
                prefill(profile)
                step = .profile
            } else {
                onAuthenticated(profile)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isWorking = false
    }

    private func prefill(_ profile: UserProfile) {
        displayName = profile.displayName == "Unio User" ? "" : profile.displayName
        username = profile.username == "@unio" ? "" : profile.username
    }

    private func shouldCollectProfileDetails(for profile: UserProfile) -> Bool {
        let displayName = profile.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let username = profile.username.trimmingCharacters(in: .whitespacesAndNewlines)
        return displayName.isEmpty || displayName == "Unio User" || username.isEmpty || username == "@unio"
    }

    private func character(at index: Int, in value: String) -> String {
        guard index < value.count else { return "" }
        return String(value[value.index(value.startIndex, offsetBy: index)])
    }
}

private struct OnboardingSlide: Identifiable {
    let id = UUID()
    let index: Int
    let title: String
    let subtitle: String
    let systemImage: String

    static let slides = [
        OnboardingSlide(index: 0, title: "Сообщения без шума", subtitle: "Личные чаты, группы, каналы и защищённые переписки в одном месте.", systemImage: "bubble.left.and.bubble.right.fill"),
        OnboardingSlide(index: 1, title: "Лента и истории", subtitle: "Публикуйте мысли, фото, видео и короткие истории в единой монохромной среде.", systemImage: "rectangle.stack.fill"),
        OnboardingSlide(index: 2, title: "Прямые эфиры", subtitle: "Запускайте Unio Live, общайтесь с аудиторией и собирайте сообщества.", systemImage: "dot.radiowaves.left.and.right"),
        OnboardingSlide(index: 3, title: "Unio AI", subtitle: "Ассистент помогает писать, переводить и модерировать контент.", systemImage: "sparkles")
    ]
}

private struct MonochromeIllustration: View {
    let systemImage: String
    @Environment(\.unioPalette) private var palette

    var body: some View {
        ZStack {
            Circle()
                .fill(palette.inverseSurface)
                .frame(width: 180, height: 180)
            Image(systemName: systemImage)
                .font(.system(size: 68, weight: .bold))
                .foregroundStyle(palette.inverseText)
        }
    }
}

private struct BackButton: View {
    let action: () -> Void
    @Environment(\.unioPalette) private var palette

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
                .frame(width: 42, height: 42)
                .background(Circle().fill(palette.surface))
        }
        .accessibilityLabel("Назад")
    }
}

private struct ProviderAuthButton: View {
    let provider: AuthProvider
    let assetName: String
    let action: () -> Void
    @Environment(\.unioPalette) private var palette

    var body: some View {
        Button {
            UnioHaptics.medium()
            action()
        } label: {
            Image(assetName)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundStyle(palette.textPrimary)
                .frame(width: 23, height: 23)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(palette.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(palette.separator, lineWidth: 0.8)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Войти через \(provider.title)")
    }
}
