#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SOURCE_DIR="$PROJECT_DIR/WakeLog"

export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

echo "Type-checking Swift files..."
$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc \
    -typecheck \
    -sdk $DEVELOPER_DIR/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk \
    -target arm64-apple-ios17.0-simulator \
    "$SOURCE_DIR"/*.swift

echo "Type check passed!"
