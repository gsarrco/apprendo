#!/usr/bin/env bash
set -euo pipefail

# Build a signed release APK for Apprendo.
#
# Prerequisites (one-time):
#   - Android Studio / Android SDK and a JDK installed.
#   - scripts/setup-android-signing.sh has been run to create the keystore.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

PROPS="$HOME/.apprendo/signing/keystore.properties"
if [ ! -f "$PROPS" ]; then
  echo "Missing $PROPS" >&2
  echo "Run scripts/setup-android-signing.sh first to create the release keystore." >&2
  exit 1
fi

echo "==> Building web assets (VITE_PLATFORM=android, service worker disabled) and syncing to android/"
npm run build:android

echo "==> Assembling signed release APK"
( cd android && ./gradlew assembleRelease )

SRC_APK="android/app/build/outputs/apk/release/app-release.apk"
if [ ! -f "$SRC_APK" ]; then
  echo "Expected signed APK not found at $SRC_APK" >&2
  if [ -f "android/app/build/outputs/apk/release/app-release-unsigned.apk" ]; then
    echo "Found an UNSIGNED apk instead — the release signingConfig did not apply." >&2
    echo "Check that $PROPS is present and valid." >&2
  fi
  exit 1
fi

OUT_DIR="dist-android"
OUT_APK="$OUT_DIR/apprendo-release.apk"
mkdir -p "$OUT_DIR"
cp "$SRC_APK" "$OUT_APK"

echo
echo "==> Signed APK: $OUT_APK"

if command -v apksigner >/dev/null 2>&1; then
  apksigner verify --print-certs "$OUT_APK"
else
  echo "(apksigner not on PATH — skipping verification."
  echo " It lives in \$ANDROID_HOME/build-tools/<version>/apksigner.)"
fi
