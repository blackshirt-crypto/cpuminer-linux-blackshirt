#!/bin/sh
# cpuminer-linux-blackshirt build script
# Optimized for x86_64 with AVX2/AES support
make distclean || echo clean
rm -f config.status
./autogen.sh || echo done
CFLAGS="-O3 -march=native -Wall" ./configure --with-curl
make -j $(nproc)
strip -s cpuminer
echo "Build complete: cpuminer"
