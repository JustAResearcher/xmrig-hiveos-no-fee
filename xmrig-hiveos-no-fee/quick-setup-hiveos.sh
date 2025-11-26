#!/bin/bash

# Quick setup for HiveOS - download and apply patches
# Usage: bash quick-setup-hiveos.sh

# Download xmrig if not present
if [ ! -d "xmrig-6.23.0" ]; then
    echo "Downloading XMRig 6.23.0..."
    wget https://github.com/xmrig/xmrig/archive/refs/tags/v6.23.0.tar.gz
    tar xzf v6.23.0.tar.gz
    rm v6.23.0.tar.gz
fi

cd xmrig-6.23.0

# Apply patches
echo "Applying no-fee patches..."

# Patch 1: Set default donation to 0
cat > donate.patch << 'EOF'
--- a/src/donate.h
+++ b/src/donate.h
@@ -40,7 +40,7 @@ constexpr const int kDonateHost_Version = 1;
  * Switching is instant and only happens after a successful connection, so you never lose any hashes.
  * 
  * If you plan on changing donations to 0%, please consider making a one-off donation to my wallet:
- * XMR: 48edfHu7V9Z84YzzMa6fUueoELZ9ZRXq9VetWzYGzKt52XU5xvqgzYnDK9URnRoJMk1j8nLwEVsaSWJ4fhdUyZijBGUicoD
+ * (Developer donation disabled by user)
  */
-constexpr const int kDefaultDonateLevel = 0;
+constexpr const int kDefaultDonateLevel = 0;  // DISABLED - No developer fee
 constexpr const int kMinimumDonateLevel = 0;
EOF

patch -p1 < donate.patch 2>/dev/null || echo "Patch already applied or not needed"

# Patch 2: Set donation in config to 0
sed -i 's/"donate-level": 1,/"donate-level": 0,/' src/config.json
sed -i 's/"donate-over-proxy": 1,/"donate-over-proxy": 0,/' src/config.json

echo "Build ready! Run:"
echo "  mkdir build && cd build"
echo "  cmake .. -DCMAKE_BUILD_TYPE=Release"
echo "  make -j\$(nproc)"
