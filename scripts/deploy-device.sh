#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"

# Ensure we use Xcode's toolchain (not just Command Line Tools)
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

echo "=== Deploy WakeLog to Connected Device ==="
echo ""

# Check Xcode is available
if [ ! -d "$DEVELOPER_DIR" ]; then
    echo "Error: Xcode not found at /Applications/Xcode.app"
    echo "Please install Xcode from the App Store."
    exit 1
fi

# Check ios-deploy is available
if ! command -v ios-deploy &> /dev/null; then
    echo "Error: ios-deploy not found"
    echo "Install it with: brew install ios-deploy"
    exit 1
fi

# Check for connected devices
echo "Looking for connected iOS devices..."
DEVICE_INFO=$(ios-deploy -c -t 5 2>&1 || true)

if echo "$DEVICE_INFO" | grep -q "Found"; then
    echo "$DEVICE_INFO" | grep "Found"
    echo ""
else
    echo "No iOS devices found. Please:"
    echo "  1. Connect your iPhone/iPad via USB"
    echo "  2. Unlock the device"
    echo "  3. Trust this computer if prompted"
    echo ""
    echo "Then run this script again."
    exit 1
fi

# Build for device
echo "Building WakeLog for iOS device..."
"$DEVELOPER_DIR/usr/bin/xcodebuild" \
    -project "$PROJECT_DIR/WakeLog.xcodeproj" \
    -scheme WakeLog \
    -sdk iphoneos \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    -allowProvisioningUpdates \
    CODE_SIGN_STYLE=Automatic \
    build \
    2>&1 | grep -E "(Compiling|Linking|BUILD|error:|warning:|Signing|Code Sign)" || true

BUILD_STATUS=${PIPESTATUS[0]}

if [ $BUILD_STATUS -ne 0 ]; then
    echo ""
    echo "Build failed! Common issues:"
    echo "  - Not signed into Xcode with your Apple ID"
    echo "  - Device not registered in your developer account"
    echo "  - Provisioning profile issues"
    echo ""
    echo "Try opening the project in Xcode to debug:"
    echo "  open $PROJECT_DIR/WakeLog.xcodeproj"
    exit 1
fi

echo ""
echo "Build succeeded!"
echo ""

# Find the built app
APP_PATH="$BUILD_DIR/DerivedData/Build/Products/Release-iphoneos/WakeLog.app"

if [ ! -d "$APP_PATH" ]; then
    echo "Could not find built app at: $APP_PATH"
    echo "Searching for app..."
    APP_PATH=$(find "$BUILD_DIR" -name "WakeLog.app" -type d 2>/dev/null | grep "Release-iphoneos" | head -1)
    if [ -z "$APP_PATH" ]; then
        echo "Could not locate WakeLog.app"
        exit 1
    fi
    echo "Found at: $APP_PATH"
fi

# Install to device
echo "Installing WakeLog to device..."
ios-deploy --bundle "$APP_PATH" --no-wifi

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "WakeLog has been installed!"
echo ""
echo "If this is the first app from your developer account on this device:"
echo "  1. Open Settings > General > VPN & Device Management"
echo "  2. Tap your developer certificate"
echo "  3. Tap 'Trust'"
