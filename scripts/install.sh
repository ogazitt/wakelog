#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_PATH="$PROJECT_DIR/build/Release-iphonesimulator/WakeLog.app"
SIMULATOR_NAME="${1:-iPhone 15}"

export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

if [ ! -d "$APP_PATH" ]; then
    echo "App not found at $APP_PATH"
    echo "Run ./scripts/build.sh first"
    exit 1
fi

echo "Booting simulator: $SIMULATOR_NAME..."
xcrun simctl boot "$SIMULATOR_NAME" 2>/dev/null || true

echo "Installing WakeLog to $SIMULATOR_NAME..."
xcrun simctl install "$SIMULATOR_NAME" "$APP_PATH"

echo "Done! Run ./scripts/run.sh to launch the app"
