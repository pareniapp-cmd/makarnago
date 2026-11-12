#!/bin/sh
# Capacitor'ın ürettiği ios/ projesini mağaza ayarlarına getirir (Codemagic macOS makinesinde çalışır).
set -e
APP=ios/App
PLIST=$APP/App/Info.plist
PB=/usr/libexec/PlistBuddy

setkey() { $PB -c "Set :$1 $2" "$PLIST" 2>/dev/null || $PB -c "Add :$1 $3 $2" "$PLIST"; }

setkey CFBundleDisplayName "Pasta Escape" string
setkey ITSAppUsesNonExemptEncryption false bool

# Yalnızca dikey yön
$PB -c "Delete :UISupportedInterfaceOrientations" "$PLIST" 2>/dev/null || true
$PB -c "Add :UISupportedInterfaceOrientations array" "$PLIST"
$PB -c "Add :UISupportedInterfaceOrientations:0 string UIInterfaceOrientationPortrait" "$PLIST"
$PB -c "Delete :UISupportedInterfaceOrientations~ipad" "$PLIST" 2>/dev/null || true

# Desteklenen diller
$PB -c "Delete :CFBundleLocalizations" "$PLIST" 2>/dev/null || true
$PB -c "Add :CFBundleLocalizations array" "$PLIST"
i=0
for l in en tr es pt-BR ru; do
  $PB -c "Add :CFBundleLocalizations:$i string $l" "$PLIST"
  i=$((i+1))
done

# Yalnızca iPhone, sürüm ve yapı numarası
PBX=$APP/App.xcodeproj/project.pbxproj
sed -i '' 's/TARGETED_DEVICE_FAMILY = "1,2";/TARGETED_DEVICE_FAMILY = 1;/g' "$PBX"
sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = ${PROJECT_BUILD_NUMBER:-1};/g" "$PBX"
sed -i '' 's/MARKETING_VERSION = [0-9.]*;/MARKETING_VERSION = 1.0;/g' "$PBX"

# Uygulama simgesi
ICON_DIR=$APP/App/Assets.xcassets/AppIcon.appiconset
for f in "$ICON_DIR"/*.png; do cp assets/icon-1024.png "$f"; done

echo "ios-setup tamam"
