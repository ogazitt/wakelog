#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIMULATOR_NAME="${1:-iPhone 15}"

echo "=== Build, Install, and Run WakeLog ==="
echo ""

"$SCRIPT_DIR/build.sh"
echo ""

"$SCRIPT_DIR/install.sh" "$SIMULATOR_NAME"
echo ""

"$SCRIPT_DIR/run.sh" "$SIMULATOR_NAME"
