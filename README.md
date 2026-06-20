# Unio iOS

Unio is a Swift 6, SwiftUI, iOS 26-only client for a monochrome social and messaging ecosystem. This repository contains the iOS client, typed service contracts, feature modules, App Intents, and configuration placeholders. Backend services are external, with Supabase as the current primary integration path.

## Project Shape

- `project.yml` is the source of truth for XcodeGen.
- `Sources/UnioApp` contains the app entry point and shell.
- `Sources/AppCore` contains routing, domain models, service protocols, fixtures, and intent handoff.
- `Sources/DesignSystem` contains monochrome design tokens and Liquid Glass UI primitives.
- `Sources/*Feature` contains SwiftUI feature modules.
- `Sources/Infrastructure` contains Supabase/GRDB/AI adapter scaffolding, preview services, and legacy Firebase shims.
- `Sources/IntentsFeature` contains App Intents and shortcuts.

## macOS Setup

```sh
brew install xcodegen swiftlint swiftformat
xcodegen generate
open Unio.xcodeproj
```

Or run:

```sh
./scripts/bootstrap_macos.sh
```

The current environment does not provide `xcrun` or an iOS Simulator, so Simulator verification is intentionally left to a macOS/Xcode environment.

## Build Checks

```sh
xcodegen generate
xcodebuild -project Unio.xcodeproj -scheme Unio -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
swiftlint
swiftformat --lint Sources Tests
```

The same sequence is encoded in `scripts/verify_macos.sh` and `.github/workflows/ios.yml`. Signed IPA export is wired in `.github/workflows/ios-release.yml` and requires production signing secrets.
