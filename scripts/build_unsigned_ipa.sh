#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "ERROR: iOS app compilation requires macOS/Xcode."
  exit 2
fi

command -v xcodebuild >/dev/null || { echo "ERROR: xcodebuild not found"; exit 2; }
command -v xcodegen >/dev/null || { echo "ERROR: xcodegen not found"; exit 2; }

rm -rf ClinicalNoteBuilder.xcodeproj build Payload ClinicalNoteBuilder-Native-unsigned.ipa
xcodegen generate

xcodebuild \
  -project ClinicalNoteBuilder.xcodeproj \
  -scheme ClinicalNoteBuilder \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath "$PWD/build" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  DEVELOPMENT_TEAM="" \
  build

APP_PATH="build/Build/Products/Release-iphoneos/ClinicalNoteBuilder.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "ERROR: App not found at $APP_PATH"
  find build/Build/Products -maxdepth 3 -name '*.app' -print || true
  exit 4
fi

mkdir -p Payload
cp -R "$APP_PATH" Payload/ClinicalNoteBuilder.app
/usr/bin/zip -qry ClinicalNoteBuilder-Native-unsigned.ipa Payload
shasum -a 256 ClinicalNoteBuilder-Native-unsigned.ipa > ClinicalNoteBuilder-Native-unsigned.ipa.sha256

echo "Built: $PWD/ClinicalNoteBuilder-Native-unsigned.ipa"
