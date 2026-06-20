# Architecture

Unio is organized as a modular SwiftUI client with XcodeGen as the project source of truth.

## Targets

- `Unio`: app entry point, auth gate, tab shell, root routing, dependency injection.
- `AppCore`: public domain models, route enums, service protocols, fixtures, App Intents handoff.
- `DesignSystem`: monochrome tokens, Liquid Glass surfaces, tab bar, reusable buttons, haptics.
- `AuthFeature`, `HomeFeature`, `ChatsFeature`, `ProfileFeature`, `AIHubFeature`: SwiftUI feature modules.
- `Infrastructure`: Supabase, local store, media, notification, and AI backend adapters, plus legacy Firebase shims.
- `IntentsFeature`: App Intents, compact entities, shortcuts, and handoff marker package.

## Routing

The app uses one `NavigationStack` per main tab: `Главная`, `Чаты`, `Профиль`. `AppRouter` owns the selected tab, three route paths, and the single active `SheetDestination`.

## Liquid Glass

Liquid Glass is intentionally limited to the floating navigation layer: bottom tab bar, top bars, floating action buttons, modal controls, and chat composer. Feed cards, chat rows, media, and scrollable content use solid monochrome surfaces to preserve readability.

## Services

Features depend on `AppCore` protocols rather than concrete SDKs. `Infrastructure` provides placeholder-safe adapters so the app can run without committed Supabase, APNs, WebSocket, or AI secrets. Real endpoints are supplied through environment/configuration outside git.

## App Intents

The first system surface includes opening a tab, opening a chat/profile, and composing a draft post. Intents write a compact `IntentHandoff`; the app consumes it at startup and when returning to the active scene.

## Assets

`AuthApple`, `AuthGoogle`, and `AuthGitHub` live in `Assets.xcassets` as preserved vector SVG image sets with template rendering. The original Google SVG is color-rich, but SwiftUI renders all three as monochrome icons to honor the Unio visual system.
