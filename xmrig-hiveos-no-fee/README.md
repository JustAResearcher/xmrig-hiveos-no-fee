# XMRig No-Fee for HiveOS

Complete XMRig 6.23.0 setup with **0% developer donation** for HiveOS mining OS.

## What's Included

- **BUILD_FOR_HIVEOS.md** - Detailed build instructions
- **install-hiveos.sh** - One-command installer for HiveOS
- **quick-setup-hiveos.sh** - Quick setup script for building
- **donate.h** - Modified source (0% donation default)
- **config.json** - Pre-configured with 0% donation

## Quick Start - 3 Ways to Install

### 🚀 Method 1: Automated Install (Easiest)

SSH into your HiveOS rig:
```bash
ssh root@<your-rig-ip>
bash install-hiveos.sh
```

This will:
- Download XMRig 6.23.0
- Apply no-fee patches automatically
- Build and install to /opt/miners/xmrig/
- Set up HiveOS integration

⏱️ **Time:** ~5-10 minutes (first build takes longer)

### 🔨 Method 2: Manual Build

SSH into HiveOS and run:
```bash
cd /home/user
bash quick-setup-hiveos.sh
cd xmrig-6.23.0/build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
cp xmrig /opt/miners/xmrig/
cp ../src/config.json /opt/miners/xmrig/
```

### 📦 Method 3: Pre-built Binary (If Available)

```bash
# Copy pre-compiled xmrig from another Linux machine
scp ./xmrig root@<your-rig-ip>:/opt/miners/xmrig/xmrig
ssh root@<your-rig-ip> chmod +x /opt/miners/xmrig/xmrig
```

## Features

✅ **100% of your hash power to YOUR pool**
- 0% developer donation (disabled in source)
- No automatic pool switching
- No hidden fee transfers

✅ **Full Algorithm Support**
- RandomX
- CryptoNight
- KawPow  
- GhostRider
- Argon2
- All others

✅ **HiveOS Integration**
- Works with flight sheets
- Compatible with monitoring
- Standard config location

## Configuration

After installation, the miner uses `/opt/miners/xmrig/config.json` with:
```json
"donate-level": 0,
"donate-over-proxy": 0,
```

To change your pool, edit the config before starting:
```bash
nano /opt/miners/xmrig/config.json
```

## Verification

Verify donation is disabled:
```bash
/opt/miners/xmrig/xmrig --donate-level 0
grep "donate-level" /opt/miners/xmrig/config.json
# Should show: "donate-level": 0,
```

## Source Code Modifications

All modifications preserve the GPLv3 license:

1. **src/donate.h**
   - Changed: `kDefaultDonateLevel = 0` (was already 0, just ensured)
   - Added comment: "DISABLED - No developer fee"

2. **src/config.json**
   - Changed: `"donate-level": 0` (was 1)
   - Changed: `"donate-over-proxy": 0` (was 1)

3. **src/base/net/stratum/Pools.cpp**
   - Inherits zero donation default from donate.h
   - No DonateStrategy created when level is 0

## Performance

- **Hash Rate:** Identical to official XMRig
- **CPU Usage:** Same as official
- **Memory:** Same as official
- **Power Draw:** Same as official

Only difference: no automatic switching to dev pool = 100% efficiency to YOUR pools.

## Troubleshooting

### Miner won't start?
```bash
chmod +x /opt/miners/xmrig/xmrig
ldd /opt/miners/xmrig/xmrig  # Check dependencies
```

### Still seeing donation attempts?
```bash
# Verify config
grep -A1 "donate" /opt/miners/xmrig/config.json

# Check for alternative configs
find /opt/miners/xmrig -name "*.json"

# Remove cached configs
rm -rf ~/.config/xmrig* 2>/dev/null
```

### HiveOS not detecting miner?
```bash
# Check permissions
ls -la /opt/miners/xmrig/xmrig

# Restart HiveOS services
systemctl restart hive
```

## Building for Other Linux Distributions

The scripts work on any Linux with build tools:
```bash
# Debian/Ubuntu
apt-get install build-essential cmake git libhwloc-dev libssl-dev libuv1-dev

# CentOS/RHEL
yum install gcc gcc-c++ cmake git hwloc-devel openssl-devel libuv-devel

# Then run install-hiveos.sh
bash install-hiveos.sh
```

## Support & Links

- **XMRig Official:** https://github.com/xmrig/xmrig
- **HiveOS:** https://hiveos.farm/
- **Build Documentation:** See BUILD_FOR_HIVEOS.md

## License

This project preserves XMRig's GPLv3 license. No fees, no licensing restrictions.

Original XMRig: Copyright (c) 2016-2024 SChernykh and xmrig contributors

---

**Questions?** Check the detailed BUILD_FOR_HIVEOS.md or test with:
```bash
/opt/miners/xmrig/xmrig --help
```
