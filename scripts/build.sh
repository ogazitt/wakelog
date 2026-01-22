#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Ensure we use Xcode's toolchain
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

echo "Building WakeLog..."
xcodebuild \
    -project "$PROJECT_DIR/WakeLog.xcodeproj" \
    -target WakeLog \
    -sdk iphonesimulator \
    -configuration Release \
    build \
    | grep -E "(Compiling|Linking|BUILD|error:|warning:)" || true

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "Build succeeded!"
    echo "App location: $PROJECT_DIR/build/Release-iphonesimulator/WakeLog.app"
else
    echo "Build failed!"
    exit 1
fi
