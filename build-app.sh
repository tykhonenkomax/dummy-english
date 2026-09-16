#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

# PRODUCT_NAME must match the Swift package target name (binary + resource
# bundle filenames). DISPLAY_NAME is only used for the shipped .app/.dmg
# filenames — renaming it never touches the internal binary, resource
# lookup, or the ~/Library/Application Support/WordTrainer/ data folder.
PRODUCT_NAME="WordTrainer"
DISPLAY_NAME="Ghostty English"

echo "==> Building release binary…"
swift build -c release --arch arm64

RELEASE_DIR=".build/release"
APP_BUNDLE="dist/${DISPLAY_NAME}.app"

rm -rf dist
mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources"

cp "$RELEASE_DIR/$PRODUCT_NAME" "$APP_BUNDLE/Contents/MacOS/$PRODUCT_NAME"
cp Info.plist "$APP_BUNDLE/Contents/Info.plist"
cp AppIcon.icns "$APP_BUNDLE/Contents/Resources/AppIcon.icns"

chmod +x "$APP_BUNDLE/Contents/MacOS/$PRODUCT_NAME"

# Ad-hoc sign so Gatekeeper shows the normal "unidentified developer"
# prompt (bypassable via right-click > Open) instead of failing outright
# with "is damaged and can't be opened" for a completely unsigned binary.
# Only works reliably on a bundle with nothing outside Contents/.
echo "==> Ad-hoc signing…"
codesign --force --deep --sign - "$APP_BUNDLE"

echo "==> App bundle ready at $APP_BUNDLE"

echo "==> Creating DMG…"
DMG_STAGE="dist/dmg-stage"
rm -rf "$DMG_STAGE"
mkdir -p "$DMG_STAGE"
cp -R "$APP_BUNDLE" "$DMG_STAGE/"
ln -s /Applications "$DMG_STAGE/Applications"

DMG_PATH="dist/${DISPLAY_NAME}.dmg"
rm -f "$DMG_PATH"
hdiutil create -volname "$DISPLAY_NAME" -srcfolder "$DMG_STAGE" -ov -format UDZO "$DMG_PATH"

echo "==> Done: $DMG_PATH"
