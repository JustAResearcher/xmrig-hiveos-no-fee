#!/bin/bash

# XMRig No-Fee Installation Script for HiveOS
# This script downloads, builds, and installs XMRig with donation disabled

set -e

echo "[*] XMRig No-Fee Installer for HiveOS"
echo "[*] This will build XMRig 6.23.0 with 0% developer donation"

# Check if running on HiveOS
if [ ! -d "/opt/miners" ]; then
    echo "[ERROR] This script should run on HiveOS (directory /opt/miners not found)"
    exit 1
fi

# Install build dependencies
echo "[*] Installing build dependencies..."
apt-get update -q
apt-get install -y -qq build-essential cmake git libhwloc-dev libssl-dev libuv1-dev > /dev/null 2>&1 || true

# Create build directory
BUILDDIR="/tmp/xmrig-build-$$"
mkdir -p "$BUILDDIR"
cd "$BUILDDIR"

# Download XMRig source
echo "[*] Downloading XMRig 6.23.0..."
wget -q https://github.com/xmrig/xmrig/archive/refs/tags/v6.23.0.tar.gz -O xmrig.tar.gz
tar xzf xmrig.tar.gz
cd xmrig-6.23.0

# Apply no-fee modifications
echo "[*] Patching for 0% donation..."

# Modify donate.h
sed -i 's/constexpr const int kDefaultDonateLevel = 0;/constexpr const int kDefaultDonateLevel = 0;  \/\/ Disabled - developer fee removed/' src/donate.h

# Modify config.json
sed -i 's/"donate-level": 1,/"donate-level": 0,/' src/config.json
sed -i 's/"donate-over-proxy": 1,/"donate-over-proxy": 0,/' src/config.json

# Build
echo "[*] Building (this may take a few minutes)..."
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DWITH_HWLOC=OFF -DWITH_OPENCL=OFF -DWITH_CUDA=OFF
make -j$(nproc)

# Install
echo "[*] Installing..."
mkdir -p /opt/miners/xmrig
cp xmrig /opt/miners/xmrig/xmrig
cp ../src/config.json /opt/miners/xmrig/config.json
chmod +x /opt/miners/xmrig/xmrig
chmod 644 /opt/miners/xmrig/config.json

# Cleanup
rm -rf "$BUILDDIR"

echo "[+] Installation complete!"
echo "[+] XMRig installed to: /opt/miners/xmrig/xmrig"
echo "[+] Configuration file: /opt/miners/xmrig/config.json"
echo "[+] Donation level: 0% (disabled)"
echo ""
echo "[*] To use this miner:"
echo "    1. Go to HiveOS web interface"
echo "    2. Create a flight sheet with XMRig"
echo "    3. The built-in config will use 0% donation"
echo ""
echo "[*] Verify donation is disabled:"
echo "    /opt/miners/xmrig/xmrig --donate-level 0"
