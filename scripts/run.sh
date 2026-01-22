#!/bin/bash
set -e

SIMULATOR_NAME="${1:-iPhone 15}"
BUNDLE_ID="com.wakelog.app"

export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

echo "Opening Simulator..."
open -a Simulator

echo "Launching WakeLog on $SIMULATOR_NAME..."
xcrun simctl launch "$SIMULATOR_NAME" "$BUNDLE_ID"

echo "WakeLog is running!"
