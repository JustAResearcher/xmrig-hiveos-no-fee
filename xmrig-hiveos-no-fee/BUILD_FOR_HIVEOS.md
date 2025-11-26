# XMRig No-Fee for HiveOS - Build Instructions

## Overview
This is a modified version of XMRig 6.23.0 with the developer donation fee completely removed.

## Key Modifications
- Developer donation level set to 0% (source code)
- `donate-level: 0` in config.json
- `donate-over-proxy: 0` in config.json
- Donation pool connections disabled

## Building for HiveOS

### Option 1: On HiveOS Linux (Recommended)

1. **SSH into your HiveOS rig:**
```bash
ssh root@<your-rig-ip>
```

2. **Clone and enter the source directory:**
```bash
cd /opt
wget https://github.com/xmrig/xmrig/releases/download/v6.23.0/xmrig-6.23.0.tar.gz
tar xzf xmrig-6.23.0.tar.gz
cd xmrig-6.23.0
```

3. **Apply the no-fee modifications:**
   - Edit `src/donate.h`:
     ```cpp
     constexpr const int kDefaultDonateLevel = 0;  // Disabled - developer fee removed
     constexpr const int kMinimumDonateLevel = 0;
     ```
   
   - Edit `src/config.json`:
     Change lines:
     ```json
     "donate-level": 1,
     "donate-over-proxy": 1,
     ```
     To:
     ```json
     "donate-level": 0,
     "donate-over-proxy": 0,
     ```

4. **Build:**
```bash
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

5. **Verify the binary:**
```bash
./xmrig --version
./xmrig --help
```

6. **Install:**
```bash
cp xmrig /opt/miners/xmrig/xmrig
cp ../src/config.json /opt/miners/xmrig/config.json
```

### Option 2: Cross-compile from another Linux machine

```bash
git clone https://github.com/xmrig/xmrig.git
cd xmrig
git checkout v6.23.0

# Modify source files as above

mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DWITH_HWLOC=OFF
make -j$(nproc)

# Transfer binary to HiveOS:
scp xmrig root@<your-rig-ip>:/opt/miners/xmrig/
```

### Option 3: Use pre-built binary

If you have a pre-built Linux binary:

```bash
# Copy to HiveOS
scp xmrig root@<your-rig-ip>:/opt/miners/xmrig/xmrig
chmod +x /opt/miners/xmrig/xmrig
```

## Configuration for HiveOS

1. **HiveOS Web Interface Method:**
   - Go to Flight Sheet settings
   - Select XMRig as your miner
   - The included config.json will use 0% donation automatically

2. **Manual Configuration:**
```bash
ssh root@<your-rig-ip>
nano /opt/miners/xmrig/config.json
# Verify "donate-level": 0
```

## Verification

To verify the donation is disabled:

```bash
./xmrig --donate-level 0
```

Or check the config:
```bash
grep -A2 "donate" config.json
# Should output:
# "donate-level": 0,
# "donate-over-proxy": 0,
```

## Source Code Files Modified

- `src/donate.h` - Set kDefaultDonateLevel to 0
- `src/config.json` - Set donate-level to 0
- `src/base/net/stratum/Pools.cpp` - Inherits from donate.h default

## Performance Notes

- 100% of your hash power goes to YOUR pool
- No automatic switching to donation pool
- Identical performance to official XMRig otherwise
- All features (RandomX, CryptoNight, KawPow, etc.) fully enabled

## Troubleshooting

**Binary won't run?**
- Make executable: `chmod +x xmrig`
- Check permissions: `ls -la xmrig`

**Still seeing donation?**
- Verify config.json has `"donate-level": 0`
- Clear any cached configs: `rm -rf ~/.config/xmrig*`
- Restart the miner

**HiveOS not detecting miner?**
- Copy to correct location: `/opt/miners/xmrig/xmrig`
- Restart HiveOS miner controller: `systemctl restart hive`

## License

XMRig is licensed under GPLv3. This modification preserves the license.
Original: https://github.com/xmrig/xmrig
