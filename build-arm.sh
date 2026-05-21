#!/bin/bash
# cpuminer-linux-blackshirt ARM build script
# For native compile on ARM64/Android (Termux)
make distclean || echo clean
rm -f config.status
./autogen.sh || echo done
CFLAGS="-O3 -march=armv8-a+crypto+sha2+aes -flax-vector-conversions -Wall" ./configure --with-curl
make -j $(nproc)
strip -s cpuminer
echo "Build complete: cpuminer (ARM)"
