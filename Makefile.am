
if HAVE_APPLE
# MacOS uses Homebrew to install needed packages but they aren't linked for
# the jansson test in configure. Ignore the failed test & link them now,
# different path for different CPU arch.

if ARCH_ARM64
  EXTRA_INCLUDES = -I/opt/homebrew/include
  EXTRA_LIBS     = -L/opt/homebrew/lib
else
  EXTRA_INCLUDES = -I/usr/local/include
  EXTRA_LIBS     = -L/usr/local/lib
endif

else

if WANT_JANSSON
# Can't find jansson libraries, compile the included source code.
  EXTRA_INCLUDES = -I$(top_srcdir)/compat/jansson
  EXTRA_LIBS     = -L$(top_srcdir)/compat/jansson
else
  EXTRA_INCLUDES =
  EXTRA_LIBS     =
endif

endif

EXTRA_DIST = example-cfg.json nomacro.pl

SUBDIRS = compat

ALL_INCLUDES = @PTHREAD_FLAGS@ -fno-strict-aliasing $(EXTRA_INCLUDES) -I.

bin_PROGRAMS = cpuminer

dist_man_MANS = cpuminer.1

cpuminer_SOURCES = \
  dummy.cpp \
  cpu-miner.c \
  util.c \
  api.c \
  sysinfos.c \
  algo-gate-api.c\
  malloc-huge.c \
  simd-utils/simd-constants.c \
  algo/scrypt/scrypt.c \
  algo/scrypt/scrypt-core-4way.c \
  algo/scrypt/neoscrypt.c \
  algo/sha/sha1.c \
  algo/sha/sha1-hash.c \
  algo/sha/sha256-hash.c \
  algo/sha/sph_sha2.c \
  algo/sha/sph_sha2big.c \
  algo/sha/sha256-hash-4way.c \
  algo/sha/sha512-hash-4way.c \
  algo/sha/hmac-sha256-hash.c \
  algo/sha/hmac-sha256-hash-4way.c \
  algo/sha/sha256d.c \
  algo/sha/sha256d-4way.c \
  algo/sha/sha256t-gate.c \
  algo/sha/sha256t-4way.c \
  algo/sha/sha256q-4way.c \
  algo/sha/sha256q.c \
  algo/sha/sha512256d-4way.c \
  algo/sha/sha256dt.c \
  algo/whirlpool/sph_whirlpool.c \
  algo/whirlpool/whirlpool-gate.c \
  algo/whirlpool/whirlpool.c \
  algo/whirlpool/whirlpoolx.c \
  algo/blake/sph_blake2b.c \
  algo/yespower/yespower-gate.c \
  algo/yespower/yespower-blake2b.c \
  algo/yespower/crypto/hmac-blake2b.c \
  algo/yespower/yescrypt-r8g.c \
  algo/yespower/yespower-opt.c \
  algo/yespower/yespower-ref.c \
  algo/yespower/yespower-blake2b-ref.c

if HAVE_WINDOWS
   cpuminer_SOURCES += compat/winansi.c
endif

if USE_ASM
   disable_flags =
   cpuminer_SOURCES += asm/neoscrypt_asm.S
else
   disable_flags = -DNOASM
endif

cpuminer_LDFLAGS = @LDFLAGS@
cpuminer_LDADD	= $(EXTRA_LIBS) @LIBCURL@ -ljansson @PTHREAD_LIBS@ @WS2_LIBS@ -lgmp -lssl -lcrypto
cpuminer_CPPFLAGS = @LIBCURL_CPPFLAGS@ $(ALL_INCLUDES)
cpuminer_CFLAGS = -Wno-pointer-sign -Wno-pointer-to-int-cast $(disable_flags)

if ARCH_ARM64
   cpuminer_CFLAGS += -flax-vector-conversions
endif

if HAVE_WINDOWS

# use to profile an object
# gprof_cflags = -pg -g3
# cpuminer_LDFLAGS += -pg
# cpuminer_CFLAGS += -fno-inline-functions -static

# copy/paste from generated Makefile
common_ccflags = $(DEFS) $(ALL_INCLUDES) $(cpuminer_CPPFLAGS) $(CPPFLAGS) $(cpuminer_CFLAGS) $(CFLAGS)

# special CFLAGS (if you find a simpler way to do that tell me ;)
cpuminer-neoscrypt.o: neoscrypt.c
	@echo "CUSTOM ${@}: ${filter %.o,${^}} ${filter %.c,${^}}"
	$(CC) $(common_ccflags) -g -O3 $(gprof_cflags) -MT $@ -MD -MP -c -o $@ $<

endif
