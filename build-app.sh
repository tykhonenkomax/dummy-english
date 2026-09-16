#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="WordTrainer"
BUILD_DIR=".build/apple/Products/Release"

echo "==> Building release binary…"
swift build -c release --arch arm64

RELEASE_DIR=".build/release"
APP_BUNDLE="dist/${APP_NAME}.app"

rm -rf dist
mkdir -p "$APP_BUNDLE/Contents/MacOS"

cp "$RELEASE_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp Info.plist "$APP_BUNDLE/Contents/Info.plist"

# The SwiftPM resource bundle must sit next to Contents/ inside the .app,
# matching Bundle.main.bundleURL + "WordTrainer_WordTrainer.bundle".
if [ -d "$RELEASE_DIR/${APP_NAME}_${APP_NAME}.bundle" ]; then
    cp -R "$RELEASE_DIR/${APP_NAME}_${APP_NAME}.bundle" "$APP_BUNDLE/${APP_NAME}_${APP_NAME}.bundle"
fi

chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

echo "==> App bundle ready at $APP_BUNDLE"

echo "==> Creating DMG…"
DMG_STAGE="dist/dmg-stage"
rm -rf "$DMG_STAGE"
mkdir -p "$DMG_STAGE"
cp -R "$APP_BUNDLE" "$DMG_STAGE/"
ln -s /Applications "$DMG_STAGE/Applications"

DMG_PATH="dist/${APP_NAME}.dmg"
rm -f "$DMG_PATH"
hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_STAGE" -ov -format UDZO "$DMG_PATH"

echo "==> Done: $DMG_PATH"
