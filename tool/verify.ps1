$ErrorActionPreference = "Stop"
flutter --version
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter build apk --debug
if ($env:OS -eq "Windows_NT") {
  flutter build windows --debug
}
Write-Host "Static analysis, unit/widget tests and debug build completed successfully."
Write-Host "For the E2E test, run: flutter test integration_test -d <device-id>"
