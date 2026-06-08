#!/bin/bash
# Loosely based on https://github.com/LeDrew2017/FreeRunnerKernel/blob/7a99c2fe668a064942d124d805e79034674757a6/build.sh

DEVICE="nairo"
OUT="out"
CONFIGS=(
    "vendor/lito-perf_defconfig"
    "vendor/ext_config/moto-lito.config"
    "vendor/ext_config/nairo-default.config"
    "vendor/debugfs.config"
    "vendor/ext_config/debug-lito-nairo.config"
)
ADDITIONAL_BUILD_FLAGS=(
    "Image"
    "modules"
)

export PATH="/usr/lib/ccache:$HOME/toolchain/bin:$PATH"
export ARCH=arm64

perform_clean() {
    echo "🧹 Cleaning up..."
    make O="$OUT" LLVM=1 mrproper
    echo "✅ Clean complete."
}

build_kernel() {
    local image_path="$OUT/arch/arm64/boot/Image"

    echo "🔧 Starting build for: $DEVICE"

    make O="$OUT" LLVM=1 "${CONFIGS[@]}"

    local build_start
    build_start=$(date +%s)
    make O="$OUT" LLVM=1 -j"$(nproc)" "${ADDITIONAL_BUILD_FLAGS[@]}"
    local build_end
    build_end=$(date +%s)
    local duration=$((build_end - build_start))

    if [ ! -f "$image_path" ]; then
        echo "❌ Build failed after $(printf "%02d:%02d" $((duration / 60)) $((duration % 60)))"
        exit 1
    fi
    echo "✅ Build completed in $(printf "%02d:%02d" $((duration / 60)) $((duration % 60)))"
}

boot_repack() {
    cd pack
    rm boot.img -f
    gzip -d -k og-boot.img.gz
    mkdir boot
    cd boot
    ../magiskboot unpack ../og-boot.img
    cp ../../out/arch/arm64/boot/Image kernel
    ../magiskboot repack ../og-boot.img ../boot.img
    cd ..
    rm boot/ -rf
    echo "✅ Done repacking boot image."
    cd ..
}

modules_repack() {
    make O="$OUT" LLVM=1 INSTALL_MOD_PATH=$(pwd)/pack/mods_og INSTALL_MOD_STRIP=1 modules_install
    cd pack
    rm vendor_dlkm.img -f
    mkdir modules
    mkdir dlkm
    gzip -d -k og-vendor_dlkm.img.gz -c > vendor_dlkm.img 
    python3 fix_modules.py
    sudo mount vendor_dlkm.img dlkm
    sudo rm dlkm/lib/modules/*.ko -rf
    sudo cp modules/* dlkm/lib/modules/
    sudo chcon u:object_r:vendor_file:s0 dlkm/lib/modules/*
    sudo umount dlkm
    rm dlkm modules mods_og -rf
    echo "✅ Done repacking vendor_dlkm image."
    cd ..
}

if [[ "$1" == "--clean" ]]; then
    perform_clean
    exit 0
fi

if [[ "$1" == "--cfg" ]]; then
    make O="$OUT" LLVM=1 "${CONFIGS[@]}"
    exit 0
fi

if [[ "$1" == "--menu" ]]; then
    make O="$OUT" LLVM=1 menuconfig
    exit 0
fi

if [[ "$1" == "--ncfg" ]]; then
    make O="$OUT" LLVM=1 nconfig
    exit 0
fi

if [[ "$1" == "--repack" ]]; then
    boot_repack
    modules_repack
    exit 0
fi

if [[ "$1" == "--boot" ]]; then
    boot_repack
    exit 0
fi

if [[ "$1" == "--modules" ]]; then
    modules_repack
    exit 0
fi

if [[ "$1" != "--inc" ]]; then
   perform_clean
fi

build_kernel
boot_repack
modules_repack
echo "🎉 Build for $DEVICE is complete."