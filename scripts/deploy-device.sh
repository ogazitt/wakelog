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

# Check ios-deploy is available (used for device detection)
if ! command -v ios-deploy &> /dev/null; then
    echo "Error: ios-deploy not found"
    echo "Install it with: brew install ios-deploy"
    exit 1
fi

# Check for connected devices and get UDID
echo "Looking for connected iOS devices..."
DEVICE_INFO=$(ios-deploy -c -t 5 2>&1 || true)

if ! echo "$DEVICE_INFO" | grep -q "Found"; then
    echo "No iOS devices found. Please:"
    echo "  1. Connect your iPhone/iPad via USB"
    echo "  2. Unlock the device"
    echo "  3. Trust this computer if prompted"
    echo "  4. Enable Developer Mode (Settings > Privacy & Security > Developer Mode)"
    echo ""
    echo "Then run this script again."
    exit 1
fi

# Extract device info - get the first iPhone/iPad found
DEVICE_LINE=$(echo "$DEVICE_INFO" | grep "Found" | grep -v "Watch" | head -1)
echo "$DEVICE_LINE"
echo ""

# Extract UDID (first field after "Found")
DEVICE_UDID=$(echo "$DEVICE_LINE" | sed -n "s/.*Found \([^ ]*\).*/\1/p")

if [ -z "$DEVICE_UDID" ]; then
    echo "Could not determine device UDID"
    exit 1
fi

# Extract device name
DEVICE_NAME=$(echo "$DEVICE_LINE" | sed -n "s/.*a\.k\.a\. '\([^']*\)'.*/\1/p")
if [ -z "$DEVICE_NAME" ]; then
    DEVICE_NAME="iOS Device"
fi

echo "Deploying to: $DEVICE_NAME ($DEVICE_UDID)"
echo ""

# Build and install using xcodebuild with specific device destination
# This automatically registers new devices and updates provisioning profiles
echo "Building and installing WakeLog..."
echo "(This may take a moment - Xcode will register the device if needed)"
echo ""

"$DEVELOPER_DIR/usr/bin/xcodebuild" \
    -project "$PROJECT_DIR/WakeLog.xcodeproj" \
    -scheme WakeLog \
    -configuration Release \
    -destination "platform=iOS,id=$DEVICE_UDID" \
    -allowProvisioningUpdates \
    -allowProvisioningDeviceRegistration \
    CODE_SIGN_STYLE=Automatic \
    2>&1 | grep -E "(Compiling|Linking|BUILD|error:|warning:|Signing|Code Sign|Registering|Installing)" || true

BUILD_STATUS=${PIPESTATUS[0]}

if [ $BUILD_STATUS -ne 0 ]; then
    echo ""
    echo "Build/install failed! Common issues:"
    echo "  - Not signed into Xcode with your Apple ID"
    echo "  - Developer Mode not enabled on device"
    echo "  - Device not trusted"
    echo ""
    echo "Try deploying from Xcode directly:"
    echo "  open $PROJECT_DIR/WakeLog.xcodeproj"
    echo "  Select the device and press Cmd+R"
    exit 1
fi

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "WakeLog has been installed on $DEVICE_NAME!"
echo ""
echo "If this is the first app from your developer account on this device:"
echo "  1. Open Settings > General > VPN & Device Management"
echo "  2. Tap your developer certificate"
echo "  3. Tap 'Trust'"
