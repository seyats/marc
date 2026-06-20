#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required to install XcodeGen, SwiftLint, and SwiftFormat." >&2
  exit 1
fi

brew list xcodegen >/dev/null 2>&1 || brew install xcodegen
brew list swiftlint >/dev/null 2>&1 || brew install swiftlint
brew list swiftformat >/dev/null 2>&1 || brew install swiftformat

xcodegen generate
