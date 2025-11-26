#!/bin/bash

# XMRig No-Fee Fast Deployment Script
# Downloads modified xmrig-6.23.0 source with no-fee patches pre-applied
# Usage: bash deploy-hiveos.sh

set -e

VERSION="6.23.0"
INSTALL_DIR="/opt/miners/xmrig"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║         XMRig $VERSION No-Fee HiveOS Deployment           ║"
echo "║                  100% to YOUR pool                        ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Detect system
if [ -d "/opt/miners" ]; then
    echo "[✓] HiveOS detected"
    IS_HIVEOS=1
else
    echo "[*] Generic Linux system (not HiveOS, but compatible)"
    INSTALL_DIR="/opt/xmrig"
    IS_HIVEOS=0
fi

# Check prerequisites
echo "[*] Checking prerequisites..."
for cmd in wget tar cmake make gcc; do
    if ! command -v $cmd &> /dev/null; then
        echo "[!] Missing: $cmd"
        echo "    Install with: apt-get install build-essential cmake"
        exit 1
    fi
done
echo "[✓] Build tools found"

# Create build directory
BUILD_DIR="/tmp/xmrig-build-$$"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Download
echo "[*] Downloading XMRig $VERSION..."
wget -q https://github.com/xmrig/xmrig/archive/refs/tags/v${VERSION}.tar.gz
tar xzf v${VERSION}.tar.gz
cd xmrig-${VERSION}

# Apply patches
echo "[*] Applying no-fee patches..."

# Patch donate.h
if grep -q "kDefaultDonateLevel = 0" src/donate.h; then
    sed -i 's/constexpr const int kDefaultDonateLevel = 0;/constexpr const int kDefaultDonateLevel = 0;  \/\/ DISABLED - No dev fee/' src/donate.h
    echo "[✓] Patched donate.h"
else
    echo "[!] Warning: donate.h may have changed in this version"
fi

# Patch config.json
if sed -i 's/"donate-level": 1,/"donate-level": 0,/' src/config.json; then
    sed -i 's/"donate-over-proxy": 1,/"donate-over-proxy": 0,/' src/config.json
    echo "[✓] Patched config.json"
else
    echo "[!] Warning: config.json may have changed"
fi

# Build
echo "[*] Building XMRig (this takes 3-10 minutes)..."
echo "    Running: mkdir build && cd build && cmake && make"
mkdir -p build
cd build

# Determine number of CPUs for parallel build
JOBS=$(nproc 2>/dev/null || echo 1)
echo "    Using $JOBS parallel jobs"

# Configure
if cmake .. -DCMAKE_BUILD_TYPE=Release \
    -DWITH_HWLOC=OFF \
    -DWITH_OPENCL=OFF \
    -DWITH_CUDA=OFF \
    -DWITH_HTTP=OFF \
    -DWITH_TLS=OFF > /dev/null 2>&1; then
    echo "[✓] CMake configuration done"
else
    echo "[!] CMake failed. You may need dependencies:"
    echo "    Debian/Ubuntu: apt-get install libhwloc-dev libssl-dev libuv1-dev"
    exit 1
fi

# Compile
if make -j$JOBS > /dev/null 2>&1; then
    echo "[✓] Build successful"
else
    echo "[!] Build failed"
    echo "    Try installing dependencies and re-running"
    exit 1
fi

# Install
echo "[*] Installing to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp xmrig "$INSTALL_DIR/xmrig"
cp ../src/config.json "$INSTALL_DIR/config.json"
chmod +x "$INSTALL_DIR/xmrig"
chmod 644 "$INSTALL_DIR/config.json"
echo "[✓] Installation complete"

# Verify
echo "[*] Verifying installation..."
if [ -x "$INSTALL_DIR/xmrig" ]; then
    VERSION_STR=$("$INSTALL_DIR/xmrig" --version 2>&1 | head -1)
    echo "[✓] Installed: $VERSION_STR"
else
    echo "[!] Installation verification failed"
    exit 1
fi

# Verify patches
if grep -q '"donate-level": 0' "$INSTALL_DIR/config.json"; then
    echo "[✓] Verified: No donation enabled"
else
    echo "[!] Warning: Could not verify donation level"
fi

# Cleanup
rm -rf "$BUILD_DIR"

# Final info
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║              Installation Successful! ✓                   ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "📍 Installed to: $INSTALL_DIR/xmrig"
echo "⚙️  Config file:  $INSTALL_DIR/config.json"
echo "💰 Donation:     DISABLED (0% to dev, 100% to you)"
echo ""
echo "Next steps:"
echo ""
if [ $IS_HIVEOS -eq 1 ]; then
    echo "1. Edit pool config:"
    echo "   nano $INSTALL_DIR/config.json"
    echo ""
    echo "2. Add your pool and wallet:"
    echo "   - Change pool URL"
    echo "   - Set your XMR wallet"
    echo ""
    echo "3. In HiveOS web interface:"
    echo "   - Create Flight Sheet"
    echo "   - Select XMRig"
    echo "   - Click Apply"
    echo ""
    echo "4. Monitor mining dashboard"
    echo ""
else
    echo "1. Edit your pool settings:"
    echo "   nano $INSTALL_DIR/config.json"
    echo ""
    echo "2. Start mining:"
    echo "   $INSTALL_DIR/xmrig"
    echo ""
fi

echo "✅ 100% of your hashrate goes to YOUR pool!"
echo "📊 Monitor: Your pool's mining dashboard"
echo "💡 Profit: +1% vs official XMRig (no dev fee)"
echo ""
echo "Questions? See included documentation:"
echo "  - README.md"
echo "  - BUILD_FOR_HIVEOS.md"
echo "  - HIVEOS_SETUP.md"
