#!/usr/bin/env bash
set -euo pipefail

OUT="${1:-noema-upload.jks}"
ALIAS="${2:-noema-upload}"

if [[ -e "$OUT" ]]; then
  echo "Refusing to overwrite existing keystore: $OUT" >&2
  exit 1
fi

if ! command -v keytool >/dev/null 2>&1; then
  echo "keytool not found. Install a JDK (Java 17 or newer) first." >&2
  exit 1
fi

echo "Creating Google Play upload keystore: $OUT"
echo "Alias: $ALIAS"
echo "Passwords will be requested interactively and are not written by this script."

keytool -genkeypair \
  -v \
  -keystore "$OUT" \
  -storetype JKS \
  -alias "$ALIAS" \
  -keyalg RSA \
  -keysize 4096 \
  -validity 10000 \
  -dname "CN=NOEMA AI, OU=Software, O=NOEMA AI, C=DE"

echo
echo "Created: $OUT"
echo "Keep this file and its passwords private and backed up. Never commit it to GitHub."
