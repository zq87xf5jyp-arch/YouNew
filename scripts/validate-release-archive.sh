#!/bin/sh
set -eu

ARCHIVE_PATH="${1:-/tmp/YouNew-AppStoreReady.xcarchive}"
APP_PATH="$ARCHIVE_PATH/Products/Applications/YouNew.app"

if [ ! -d "$APP_PATH" ]; then
  echo "FAIL: app bundle not found at $APP_PATH" >&2
  exit 1
fi

codesign --verify --deep --strict --verbose=2 "$APP_PATH"
plutil -lint "$APP_PATH/Info.plist"

if [ ! -f "$APP_PATH/PrivacyInfo.xcprivacy" ]; then
  echo "FAIL: PrivacyInfo.xcprivacy is missing from the archive" >&2
  exit 1
fi

ENTITLEMENTS="$(codesign -d --entitlements :- "$APP_PATH" 2>/dev/null)"
SIGNATURE="$(codesign -dvvv "$APP_PATH" 2>&1)"

echo "$SIGNATURE" | sed -n '/^Identifier=/p;/^Authority=/p;/^TeamIdentifier=/p'
echo "Bundle: $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP_PATH/Info.plist")"
echo "Version: $(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Info.plist") ($( /usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$APP_PATH/Info.plist" ))"
echo "Size: $(du -sh "$APP_PATH" | awk '{print $1}')"

if echo "$ENTITLEMENTS" | grep -q '<key>get-task-allow</key><true/>'; then
  echo "NOT APP STORE READY: archive uses a development entitlement (get-task-allow=true)." >&2
  exit 2
fi

if ! echo "$SIGNATURE" | grep -q '^Authority=Apple Distribution:'; then
  echo "NOT APP STORE READY: Apple Distribution signature is required." >&2
  exit 2
fi

echo "PASS: archive structure, privacy manifest, signature and distribution entitlements are valid."
