# Verification

This repository was scaffolded in a Windows environment without `xcrun`, Xcode, or iOS Simulator access. Run the full verification pass on macOS.

## Required macOS Commands

```sh
brew install xcodegen swiftlint swiftformat
xcodegen generate
xcodebuild -project Unio.xcodeproj -scheme Unio -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
xcodebuild -project Unio.xcodeproj -scheme Unio -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
swiftlint
swiftformat --lint Sources Tests
```

For a live Supabase-backed run, export `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_STORAGE_BUCKET` before generating the project.

Or:

```sh
./scripts/verify_macos.sh
```

## Snapshot Rendering

Snapshot scenarios are present but skipped by default so the unit suite can run before reference images exist.

```sh
UNIO_ENABLE_SNAPSHOTS=1 xcodebuild -project Unio.xcodeproj -scheme Unio -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
```

## Simulator Note

The Build iOS Apps plugin could not list simulators in this environment because `xcrun` is unavailable. No Simulator assertions were performed here.
