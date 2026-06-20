#!/usr/bin/env bash
set -euo pipefail

DESTINATION="${UNIO_DESTINATION:-platform=iOS Simulator,name=iPhone 16 Pro}"

xcodegen generate
xcodebuild -project Unio.xcodeproj -scheme Unio -destination "$DESTINATION" build
xcodebuild -project Unio.xcodeproj -scheme Unio -destination "$DESTINATION" test
swiftlint
swiftformat --lint Sources Tests
