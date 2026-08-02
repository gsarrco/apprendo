#!/usr/bin/env bash
set -euo pipefail

# One-time setup: generate an isolated release keystore for signing the
# Apprendo Android APK. The keystore and its passwords live OUTSIDE the repo,
# in ~/.apprendo/signing (readable only by you), and are never committed.
#
# Back this folder up ENCRYPTED (e.g. into a password manager). Losing it
# means you can never ship an update under the same app identity again.

SIGNING_DIR="$HOME/.apprendo/signing"
KEYSTORE="$SIGNING_DIR/apprendo-release.keystore"
PROPS="$SIGNING_DIR/keystore.properties"
ALIAS="apprendo"

command -v keytool >/dev/null 2>&1 || {
  echo "keytool not found on PATH." >&2
  echo "Install a JDK (Android Studio bundles one) and ensure keytool is available." >&2
  exit 1
}

mkdir -p "$SIGNING_DIR"
chmod 700 "$SIGNING_DIR"

if [ -f "$KEYSTORE" ]; then
  echo "A keystore already exists at:" >&2
  echo "  $KEYSTORE" >&2
  echo "Refusing to overwrite it (that would change the app identity)." >&2
  echo "Delete it manually only if you are certain you want a new identity." >&2
  exit 1
fi

echo "Generating a release keystore at:"
echo "  $KEYSTORE"
echo "keytool will prompt for a keystore password, a key password, and your"
echo "identity (name / organization). These prompts are handled by keytool and"
echo "are never captured by this script."
echo
keytool -genkeypair -v \
  -keystore "$KEYSTORE" \
  -alias "$ALIAS" \
  -keyalg RSA \
  -keysize 4096 \
  -validity 10000

chmod 600 "$KEYSTORE"

# Gradle reads the passwords from keystore.properties. keytool does not hand
# them back to us, so prompt once more (hidden input) to persist them here.
echo
read -r -s -p "Re-enter the keystore (store) password to save for Gradle: " STORE_PASSWORD
echo
read -r -s -p "Re-enter the key password (leave blank if same as store): " KEY_PASSWORD
echo
if [ -z "$KEY_PASSWORD" ]; then
  KEY_PASSWORD="$STORE_PASSWORD"
fi

umask 177
cat > "$PROPS" <<EOF
storeFile=$KEYSTORE
keyAlias=$ALIAS
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
EOF
chmod 600 "$PROPS"

echo
echo "Wrote $PROPS (chmod 600)."
echo
echo "IMPORTANT: back up $SIGNING_DIR encrypted. If you lose it you lose the"
echo "ability to update the published app under the same signature."
echo
echo "You can now build a signed APK with:  npm run apk"
