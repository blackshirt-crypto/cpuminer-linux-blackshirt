# cpuminer-linux-blackshirt

x86/Linux CPU miner — optimized for **civiclight**, yespower, yescrypt, sha256d, scrypt, and whirlpool. Built for spec mining small coins before difficulty rises.

## ⚡ Quick Start — One Command Setup (Recommended)

```bash
curl -L -o setup-cpuminer-blackshirt.sh https://github.com/blackshirt-crypto/cpuminer-linux-blackshirt/releases/download/v26.2/setup-cpuminer-blackshirt.sh
chmod +x setup-cpuminer-blackshirt.sh
./setup-cpuminer-blackshirt.sh
```

The setup script will:
1. Download the pre-built x86 binary into `~/cpuminer-blackshirt/`
2. Ask you for: algorithm, pool, wallet, worker name, password, threads
3. Save your config as `~/cpuminer-blackshirt/start-{algo}.sh`
4. Start mining with a clean colored display

**To mine again after setup:**
```bash
~/cpuminer-blackshirt/start-civiclight.sh
```

**To change settings:**
```bash
~/cpuminer-blackshirt/reconfigure.sh
```

## 🔧 Alternative — Build from Source

```bash
git clone https://github.com/blackshirt-crypto/cpuminer-linux-blackshirt.git
cd cpuminer-linux-blackshirt
./autogen.sh
CFLAGS="-O3 -march=native" ./configure --with-curl
make -j$(nproc)
```

## 🎯 Supported Algorithms

Enter the TYPE — not the coin ticker (e.g. type `civiclight` not `CIVIC`):

| Algorithm | Coin | Performance |
|-----------|------|------------|
| `civiclight` | **CivicNet (CIVIC)** | ✅ Excellent |
| `yespower` | Small yespower coins | ✅ Excellent |
| `yespowerr16` | Yenten (YTN) | ✅ Excellent |
| `yespower-b2b` | blake2b yespower variants | ✅ Excellent |
| `yescrypt` | various yescrypt coins | ✅ Good |
| `yescryptr8` | yescrypt r8 variants | ✅ Good |
| `yescryptr16` | Fennec (FNNC) | ✅ Good |
| `yescryptr32` | yescrypt r32 variants | ✅ Good |
| `sha256d` | Small SHA-256d coins | ✅ Good |
| `scrypt` | Small scrypt coins* | ✅ Good |
| `whirlpool` | CapStash (CAP) | ✅ Good |

> *Scrypt for Litecoin/Dogecoin is ASIC dominated. Focus on smaller coins.

## 🪙 CivicNet (CIVIC) — Featured

CivicNet uses the **civiclight** algorithm: SHA256d → SHA256 → yespower(N=2048, r=8) → XOR → SHA256. CPU-only with hardware SHA256 and AES acceleration.

```bash
~/cpuminer-blackshirt/start-civiclight.sh
# or manually:
~/cpuminer-blackshirt/cpuminer-blackshirt -a civiclight -o stratum+tcp://POOL:PORT -u WALLET -p c=CIVIC -t 12
```

## 📈 civiclight x86 Hashrates (observed)

| CPU | Threads | Hashrate |
|-----|---------|----------|
| AMD Ryzen 5 3600 | 12 | ~2500 H/s |
| Intel Core2 Duo P8600 | 2 | ~300 H/s |

## 🔑 YIIMP Pool Password Options

Most pools accept `-p x` but YIIMP-based pools support extended options:

| Password | Effect |
|----------|--------|
| `x` | Standard default |
| `c=CIVIC` | Required for civiclight on NitroPool/YIIMP |
| `c=CIVIC,m=solo` | Solo mining mode on YIIMP |
| `c=CIVIC,ID=MyWorker` | Custom worker name on YIIMP |
| `c=CIVIC,m=solo,ID=Rig1` | Solo mode + custom worker name |

> MiningCore pools (like Blackshirt Pool) use `-p x` and worker name is appended to wallet: `-u WALLET.WorkerName`

## ⛏️ Pool Examples

```bash
# Blackshirt Pool (MiningCore, solo)
~/cpuminer-blackshirt/cpuminer-blackshirt -a civiclight -o stratum+tcp://blkshirtpool.com:4353 -u YOUR_CIVIC_ADDRESS.Rig1 -p x -t 12

# NitroPool (YIIMP, proportional)
~/cpuminer-blackshirt/cpuminer-blackshirt -a civiclight -o stratum+tcp://us.nitropool.net:3032 -u YOUR_CIVIC_ADDRESS -p c=CIVIC -t 12

# NitroPool (YIIMP, solo mode)
~/cpuminer-blackshirt/cpuminer-blackshirt -a civiclight -o stratum+tcp://us.nitropool.net:3032 -u YOUR_CIVIC_ADDRESS -p c=CIVIC,m=solo,ID=Rig1 -t 12
```

## 🔄 Reconfigure Settings

```bash
~/cpuminer-blackshirt/reconfigure.sh
```

Shows your current config and lets you update pool, wallet, worker, password, or threads.

## 🛠️ Troubleshooting

**Missing libraries:**
```bash
sudo apt-get install libboost-filesystem-dev libcurl4-openssl-dev libjansson-dev
```

**Miner won't connect:**
- Verify pool address format: `stratum+tcp://HOST:PORT`
- For NitroPool/YIIMP civiclight use `-p c=CIVIC` not `-p x`
- For MiningCore pools use `-p x`

**Not showing on YIIMP pool dashboard:**
- Use correct password format (see YIIMP Password Options above)
- Allow 3-5 minutes after first share for stats to appear

**Unknown algo error:**
- Enter algorithm TYPE not coin ticker: `civiclight` not `CIVIC`, `yescryptr16` not `FNNC`

## 🆘 Resources

- **Source code:** https://github.com/blackshirt-crypto/cpuminer-linux-blackshirt
- **Android version:** https://github.com/blackshirt-crypto/cpuminer-android-blackshirt
- **Blackshirt Pool:** https://blkshirtpool.com
- **Mining Pool Stats:** https://miningpoolstats.stream

## 🤝 Credits & Attribution

- **cpuminer-blackshirt** — x86/Linux optimized fork by [blackshirt-crypto](https://github.com/blackshirt-crypto)
- **cpuminer-opt v26.2** — Original optimized miner by [JayDDee](https://github.com/JayDDee/cpuminer-opt)
- **cpuminer-multi** — Original multi-algo base by [tpruvot](https://github.com/tpruvot/cpuminer-multi)
- **yescrypt/yespower** — Memory-hard KDF by Alexander Peslyak (Solar Designer)
- **civiclight algorithm** — CivicNet / CivicLight developer: [github.com/CivicLight/CivicNet](https://github.com/CivicLight/CivicNet)
- **civic_yespower reference** — nof8 @ [NitroPool](https://nitropool.net)

All upstream code is open source under GPL-2.0.

## ⚖️ Disclaimer

Mining cryptocurrency involves risk. Monitor hardware temperatures and electricity costs.

## 📝 License

GPL-2.0 — see [COPYING](COPYING) for full license details.

---
*Built for spec miners. Get in early, mine lean.*
