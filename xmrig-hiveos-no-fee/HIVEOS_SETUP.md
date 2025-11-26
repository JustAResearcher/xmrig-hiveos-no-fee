# HiveOS Flight Sheet Configuration Guide

## After Building XMRig No-Fee

Once you've installed XMRig using one of the methods, configure it in HiveOS:

### Step 1: Web Interface Setup

1. Open HiveOS Web Interface: `https://<your-rig-ip>` or `https://farm.hiveos.farm/`
2. Select your rig
3. Go to **Flight Sheet** tab

### Step 2: Create Flight Sheet

1. Click **"Create a new flight sheet"** or edit existing
2. Under "Miner type", select **XMRig**
3. For "Miner version", select latest or your installed version
4. Leave "Pool" settings for your preferred mining pool

### Step 3: Pool Configuration

Enter your mining pool details:
- **Pool URL:** Your pool's server (e.g., `pool.supportxmr.com:3333`)
- **Wallet:** Your XMR wallet address
- **Worker:** Optional worker name

**Example for SupportXMR:**
```
Pool: pool.supportxmr.com:3333
Wallet: YOUR_WALLET_ADDRESS_HERE
Worker: worker_1
```

### Step 4: Apply & Launch

1. Click **"Apply"** button
2. Your rig will automatically start mining with XMRig
3. Monitor hashrate in the dashboard

## Verification

### Check Donation is Disabled

**Method 1: SSH into rig**
```bash
ssh root@<rig-ip>
ps aux | grep xmrig  # Should see running xmrig process
grep "donate" /opt/miners/xmrig/config.json
# Output should show: "donate-level": 0,
```

**Method 2: Web Dashboard**
- Go to rig details
- Look for XMRig process in "Processes" tab
- Check logs for donation mentions (should be none)

**Method 3: Pool Statistics**
- Check your pool's mining statistics
- All valid shares should count toward YOUR wallet
- No mysterious switching to dev pool

## Advanced Configuration

### Custom Miner Arguments

If you need custom parameters:

1. In Flight Sheet, go to **"Miner arguments"** or **"Miner config"**
2. Add arguments like:
```
--donate-level 0
--no-tls
--print-time 60
```

### Changing Pools Without Rebuild

Edit config directly:
```bash
ssh root@<rig-ip>
nano /opt/miners/xmrig/config.json
# Modify pool, wallet, worker, etc.
```

Then restart miner:
```bash
pkill -f xmrig
sleep 2
/opt/miners/xmrig/xmrig  # Or let HiveOS restart it
```

## Monitoring

### Hashrate
- Check HiveOS dashboard for real-time hashrate
- Should match your pool's reported hashrate
- No hashrate lost to dev pool (vs official XMRig)

### Power & Temperature
- Monitor in HiveOS "Workers" page
- XMRig no-fee uses same power as official

### Profitability
- Calculate: (Your current hashrate) × (Pool reward) - (Electricity)
- vs official XMRig: +1% more profit (no dev fee)
- vs other miners: Compare at WhatToMine.com

## Profit Calculator

With XMRig no-fee running 24/7:

**Example with RandomX on MoneroOcean Pool:**
```
Hashrate: 5 kH/s
Pool fee: 0.5%
Dev fee (official XMRig): 1% 
Your fee (no-fee version): 0%

Revenue at $100/XMR:
  Official: 5 kH/s × (1 - 0.005 - 0.01) × $100 = $497.50/month
  No-fee:   5 kH/s × (1 - 0.005 - 0.00) × $100 = $502.50/month
  Extra:    +$5.00/month = $60/year
```

(This is approximately correct for typical pools/rates)

## Troubleshooting Flight Sheet

### Miner won't start
- SSH in and check: `/opt/miners/xmrig/xmrig --version`
- Verify permissions: `ls -la /opt/miners/xmrig/xmrig`
- Check logs: `/var/log/miner.log` or HiveOS interface

### Invalid pool/wallet error
- Verify your pool URL format (usually pool:port like `pool.example.com:3333`)
- Check wallet address spelling
- Test on a different pool to isolate issue

### Low hashrate
- Ensure CPU freq is normal: `cat /proc/cpuinfo | grep MHz`
- Check if RandomX config is correct (init, mode)
- Look for thermal throttling: `cat /sys/devices/virtual/thermal/*/temp`

## Popular Pools with XMRig

| Pool | URL | Fee |
|------|-----|-----|
| SupportXMR | pool.supportxmr.com:3333 | 0.6% |
| MoneroOcean | gulf.moneroocean.stream:10128 | 0% |
| Nanopool | xmr-eu1.nanopool.org:14444 | 1% |
| MineXMR | pool.minexmr.com:4444 | 1% |
| Herominers | xmr-us-east1.herominers.com:10380 | 0% |

## Next Steps

- Monitor your mining for 24 hours
- Adjust worker/rig names if needed
- Consider pool hopping for best rates
- Track profitability over time

## Support

For issues:
1. Check HiveOS documentation: https://hiveos.farm/support
2. SSH into rig and check process: `ps aux | grep xmrig`
3. Review miner logs in `/var/log/`
4. Verify network connectivity and pool access
