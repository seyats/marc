# Unio iOS

Unio — это клиент на Swift 6 и SwiftUI только для iOS 26 для монохромной социальной и мессенджерной экосистемы. В этом репозитории находятся iOS-клиент, типизированные сервисные контракты, модули функций, App Intents и конфигурационные заглушки. Backend-сервисы вынесены наружу, а текущий основной путь интеграции — Supabase.

## Структура проекта

- `project.yml` — источник правды для XcodeGen.
- `Sources/UnioApp` содержит точку входа приложения и shell.
- `Sources/AppCore` содержит роутинг, доменные модели, протоколы сервисов, фикстуры и handoff для intents.
- `Sources/DesignSystem` содержит монохромные design tokens и UI-примитивы на Liquid Glass.
- `Sources/*Feature` содержит SwiftUI-модули функций.
- `Sources/Infrastructure` содержит обвязку адаптеров Supabase/GRDB/AI, preview-сервисы и legacy-shims для Firebase.
- `Sources/IntentsFeature` содержит App Intents и shortcuts.

## Настройка на macOS

```sh
brew install xcodegen swiftlint swiftformat
xcodegen generate
open Unio.xcodeproj
```

Или запусти:

```sh
./scripts/bootstrap_macos.sh
```

В текущей среде нет `xcrun` и iOS Simulator, поэтому проверка в Simulator намеренно оставлена для macOS/Xcode-окружения.

## Проверки сборки

```sh
xcodegen generate
xcodebuild -project Unio.xcodeproj -scheme Unio -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
swiftlint
swiftformat --lint Sources Tests
```

Эта же последовательность описана в `scripts/verify_macos.sh` и `.github/workflows/ios.yml`. Подписанная сборка IPA подключена в `.github/workflows/ios-release.yml` и требует production-секретов для подписи.

Если нужен только артефакт сборки без сертификатов, используй `.github/workflows/ios-unsigned.yml`; он архивирует приложение с отключенной подписью и упаковывает `.app` в unsigned IPA для CI-проверки.
