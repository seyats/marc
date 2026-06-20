import AIHubFeature
import AppCore
import AuthFeature
import ChatsFeature
import DesignSystem
import HomeFeature
import ProfileFeature
import SwiftUI

@MainActor
struct RootView: View {
    @Binding var themeMode: ThemeMode
    @Environment(AppRouter.self) private var router
    @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.unioPalette) private var palette
    @State private var authState: AuthState = .signedOut
    @State private var didFinishSplashAuthCheck = false

    var body: some View {
        Group {
            if isSignedIn {
                appShell
            } else {
                AuthFlowView { profile in
                    authState = .signedIn(profile)
                }
            }
        }
        .task {
            guard !didFinishSplashAuthCheck else { return }
            authState = await appEnvironment.authService.currentState()
            didFinishSplashAuthCheck = true
            if let handoff = IntentHandoffStorage.consume() {
                router.apply(handoff)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active, let handoff = IntentHandoffStorage.consume() else { return }
            router.apply(handoff)
        }
    }

    private var isSignedIn: Bool {
        if case .signedIn = authState { return true }
        return false
    }

    private var appShell: some View {
        ZStack(alignment: .bottom) {
            palette.background.ignoresSafeArea()
            TabView(selection: selectedTabBinding) {
                NavigationStack(path: homePathBinding) {
                    HomeView(
                        onRoute: { router.push($0, in: .home) },
                        onSheet: { router.present($0) }
                    )
                    .navigationDestination(for: Route.self) { route in
                        routeDestination(route)
                    }
                }
                .tag(AppTab.home)

                NavigationStack(path: chatsPathBinding) {
                    ChatsView(
                        onRoute: { router.push($0, in: .chats) },
                        onSheet: { router.present($0) }
                    )
                    .navigationDestination(for: Route.self) { route in
                        routeDestination(route)
                    }
                }
                .tag(AppTab.chats)

                NavigationStack(path: profilePathBinding) {
                    ProfileView(
                        onRoute: { router.push($0, in: .profile) },
                        onSheet: { router.present($0) }
                    )
                    .navigationDestination(for: Route.self) { route in
                        routeDestination(route)
                    }
                }
                .tag(AppTab.profile)
            }
            .toolbar(.hidden, for: .tabBar)
            .animation(.spring(response: 0.32, dampingFraction: 0.78), value: router.selectedTab)

            UnioFloatingTabBar(selectedTab: selectedTabBinding)
        }
        .sheet(item: presentedSheetBinding) { sheet in
            sheetDestination(sheet)
                .presentationDetents(detents(for: sheet))
                .presentationDragIndicator(.visible)
                .unioTheme(themeMode)
        }
    }

    private var selectedTabBinding: Binding<AppTab> {
        Binding(
            get: { router.selectedTab },
            set: { router.selectedTab = $0 }
        )
    }

    private var homePathBinding: Binding<[Route]> {
        Binding(
            get: { router.homePath },
            set: { router.homePath = $0 }
        )
    }

    private var chatsPathBinding: Binding<[Route]> {
        Binding(
            get: { router.chatsPath },
            set: { router.chatsPath = $0 }
        )
    }

    private var profilePathBinding: Binding<[Route]> {
        Binding(
            get: { router.profilePath },
            set: { router.profilePath = $0 }
        )
    }

    private var presentedSheetBinding: Binding<SheetDestination?> {
        Binding(
            get: { router.presentedSheet },
            set: { router.presentedSheet = $0 }
        )
    }

    @ViewBuilder
    private func routeDestination(_ route: Route) -> some View {
        switch route {
        case let .profile(userID):
            ProfileView(
                user: profile(for: userID),
                onRoute: { router.push($0) },
                onSheet: { router.present($0) }
            )
        case let .postDetail(postID):
            PostDetailView(postID: postID)
        case let .chatThread(chatID):
            ChatThreadView(chatID: chatID) { router.present($0) }
        case let .mediaViewer(id):
            MediaViewerView(mediaID: id)
        case let .search(query):
            SearchView(query: query)
        case .settings:
            SettingsScreen(themeMode: $themeMode)
        case .security:
            SecurityView()
        case .privacy:
            PrivacyView()
        }
    }

    @ViewBuilder
    private func sheetDestination(_ sheet: SheetDestination) -> some View {
        switch sheet {
        case .composer:
            ComposerView()
        case .editProfile:
            EditProfileView()
        case .aiAssistant:
            AIAssistantView()
        case let .storyViewer(storyID):
            StoryViewerView(storyID: storyID)
        case let .liveRoom(liveID):
            LiveRoomView(liveID: liveID)
        case let .attachmentPicker(chatID):
            AttachmentPickerView(chatID: chatID)
        }
    }

    private func detents(for sheet: SheetDestination) -> Set<PresentationDetent> {
        switch sheet {
        case .aiAssistant:
            [.medium, .large]
        case .composer, .editProfile:
            [.large]
        case .attachmentPicker:
            [.height(360), .medium]
        case .storyViewer, .liveRoom:
            [.large]
        }
    }

    private func profile(for userID: String) -> UserProfile {
        [Fixtures.currentUser, Fixtures.creator, Fixtures.editor].first { $0.id == userID } ?? Fixtures.currentUser
    }
}

@MainActor
private struct SettingsScreen: View {
    @Binding var themeMode: ThemeMode
    @Environment(\.unioPalette) private var palette

    var body: some View {
        List {
            Section("Внешний вид") {
                Picker("Тема", selection: $themeMode) {
                    Text("Светлая").tag(ThemeMode.light)
                    Text("Тёмная").tag(ThemeMode.dark)
                }
                .pickerStyle(.segmented)
            }
            Section("Аккаунт") {
                NavigationLink("Папки чатов") { SettingsView() }
                NavigationLink("Уведомления и звуки") { SettingsView() }
            }
        }
        .scrollContentBackground(.hidden)
        .background(palette.background)
        .navigationTitle("Настройки")
    }
}
