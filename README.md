# cpuminer-linux-blackshirt

A focused, streamlined CPU miner built on [cpuminer-opt v26.1](https://github.com/JayDDee/cpuminer-opt) by JayDDee, maintained by [blackshirt-crypto](https://github.com/blackshirt-crypto).

## About

cpuminer-linux-blackshirt is not a ground-up rewrite — it is a deliberately stripped-down fork of cpuminer-opt focused on a small set of CPU-friendly algorithms. The goal is a cleaner, faster-building binary without the overhead of 40+ algorithms most CPU miners will never use.

### Compared to stock cpuminer-opt

| | cpuminer-opt 26.1 | cpuminer-linux-blackshirt |
|---|---|---|
| Algorithms | 40+ | 5 (focused) |
| Build time | ~5 minutes | ~2 minutes |
| Binary size | ~4MB | ~500KB |
| Hashrate (yespower) | Baseline | ~1-3% improvement* |
| Target platform | x86_64 | x86_64 + ARM64 |

*Hashrate improvement comes from compiler flag optimizations (`-march=native`) and reduced binary overhead. Results vary by CPU.

> **Honest note:** If you want to mine every possible algorithm, use JayDDee's original cpuminer-opt. This fork is for miners who know what they want to mine and want a leaner, purpose-built binary.

## Supported Algorithms

| Algorithm | Coins | ARM Friendly |
|-----------|-------|-------------|
| `yespower` | Cryply, CPUpower, Sugar | ✅ Excellent |
| `yespower-r16` | Yenten (YTN) | ✅ Excellent |
| `yescrypt` | Fennec (FNNC), various | ✅ Good |
| `yescryptr16` | Various | ✅ Good |
| `sha256d` | Small SHA coins | ✅ Good |
| `scrypt` | Small scrypt coins* | ✅ Good |
| `whirlpool` | Capstash, spec mining | ✅ Good |

*Scrypt for Litecoin/Dogecoin is ASIC dominated — not recommended. Focus on smaller coins.

## Quick Start

### Requirements

```bash
sudo apt-get install -y build-essential automake autoconf libtool \
    libcurl4-openssl-dev libssl-dev libgmp-dev zlib1g-dev
```

### Build

```bash
git clone https://github.com/blackshirt-crypto/cpuminer-linux-blackshirt.git
cd cpuminer-linux-blackshirt
./build.sh
```

### Usage

```bash
# yespower
./cpuminer -a yespower -o stratum+tcp://POOL:PORT -u WALLET -p x -t 8

# yescrypt (Fennec/FNNC)
./cpuminer -a yescryptr16 -o stratum+tcp://POOL:PORT -u WALLET -p x -t 8

# sha256d
./cpuminer -a sha256d -o stratum+tcp://POOL:PORT -u WALLET -p x -t 8

# whirlpool
./cpuminer -a whirlpool -o stratum+tcp://POOL:PORT -u WALLET -p x -t 8
```

### Benchmark

```bash
./cpuminer -a yespower --benchmark -t 8
```

## Thread Count Guide

For yespower specifically — hyperthreading **hurts** performance due to memory bandwidth contention. Use physical core count only:

| CPU | Physical Cores | Recommended Threads |
|-----|---------------|-------------------|
| Ryzen 5 3600 | 6 | 8 |
| Ryzen 7 5700X | 8 | 8-10 |
| Budget phones | 4 | 4 |
| Flagship phones | 8 | 6-8 |

> **Tip:** Test with `-t N --benchmark` and find your own sweet spot. More threads ≠ more hashrate for memory-hard algorithms.

## Build Scripts

| Script | Target | Flags |
|--------|--------|-------|
| `build.sh` | x86_64 Linux | `-march=native` |
| `build-arm.sh` | ARM64/Android | `-march=armv8-a+crypto+sha2+aes` |

## Android / Termux

For Android mining, see the companion repo:
[cpuminer-android-blackshirt](https://github.com/blackshirt-crypto/cpuminer-android-blackshirt)

## Credits & Attribution

- **cpuminer-opt v26.1** — Original optimized miner by [JayDDee](https://github.com/JayDDee/cpuminer-opt) — the foundation this project builds on
- **cpuminer-multi** — Original multi-algo base by [tpruvot](https://github.com/tpruvot/cpuminer-multi)
- **yespower/yescrypt** — Memory-hard KDF by Alexander Peslyak (Solar Designer)

All upstream code is open source under GPL-2.0.

## License

GPL-2.0 — see [COPYING](COPYING) for full license details.

---
*Built for spec miners. Get in early, mine lean.*
