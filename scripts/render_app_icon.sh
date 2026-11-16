#!/bin/sh
# Renders DSAppIcon (BingoghUI) into the app's AppIcon at 1024 x 1024.
# Run it from the repository root after changing DSAppIcon or the design tokens.
set -e

root="$(cd "$(dirname "$0")/.." && pwd)"
output="$root/Bingogh/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png"

cd "$root/Packages/BingoghUI"
BINGOGH_APP_ICON_OUTPUT="$output" swift test --filter DSAppIconTests
echo "App icon written to $output"
