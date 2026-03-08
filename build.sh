#!/bin/bash
set -e
APP_NAME="EyeBreak"
BUILD_DIR=".build"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"

swift build

rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"
cp "${BUILD_DIR}/debug/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
cp Sources/EyeBreak/Resources/Info.plist "${APP_BUNDLE}/Contents/Info.plist"
cp Sources/EyeBreak/Resources/AppIcon.icns "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"

echo "Built: ${APP_BUNDLE}"
echo "Run:   open ${APP_BUNDLE}"
