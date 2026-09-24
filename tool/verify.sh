#!/usr/bin/env sh
set -eu
flutter --version
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter build apk --debug
if [ "$(uname -s 2>/dev/null || true)" = "Windows_NT" ]; then
  flutter build windows --debug
fi
echo "Static analysis, unit/widget tests and debug build completed successfully."
echo "For the E2E test, run: flutter test integration_test -d <device-id>"
