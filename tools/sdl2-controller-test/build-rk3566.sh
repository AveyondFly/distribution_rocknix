#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
TOOLCHAIN_DEFAULT="/home/ubuntu/distribution/build.ROCKNIX-RK3566.aarch64/toolchain"
TOOLCHAIN="${1:-$TOOLCHAIN_DEFAULT}"
SYSROOT="$TOOLCHAIN/aarch64-rocknix-linux-gnu/sysroot"
TARGET_PREFIX="$SYSROOT/usr"
CC="$TOOLCHAIN/bin/aarch64-rocknix-linux-gnu-gcc"
STRIP="$TOOLCHAIN/bin/aarch64-rocknix-linux-gnu-strip"
OUT_DIR="$SCRIPT_DIR/out"
OUT_BIN="$OUT_DIR/sdl2-controller-test-rk3566"

mkdir -p "$OUT_DIR"

if [[ ! -x "$CC" ]]; then
    echo "Cross compiler not found: $CC" >&2
    exit 1
fi

"$CC" \
    --sysroot="$SYSROOT" \
    -O2 -pipe -Wall -Wextra -std=c11 \
    -D_REENTRANT \
    -I"$TARGET_PREFIX/include" \
    -I"$TARGET_PREFIX/include/SDL2" \
    -L"$TARGET_PREFIX/lib" \
    -Wl,-rpath-link,"$TARGET_PREFIX/lib" \
    -Wl,-rpath-link,"$SYSROOT/lib" \
    "$SCRIPT_DIR/src/controller_test.c" \
    -o "$OUT_BIN" \
    -lSDL2 -lm -pthread

"$STRIP" "$OUT_BIN"

echo "Built: $OUT_BIN"
