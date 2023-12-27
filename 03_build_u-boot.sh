#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)
wdir=`pwd`
CC=${CC:-"${wdir}/riscv-toolchain/bin/riscv64-linux-"}

make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} distclean

make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} microchip_mpfs_icicle_defconfig
#make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} menuconfig

make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} olddefconfig

make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} savedefconfig
cp -v ./u-boot/defconfig ./u-boot/configs/microchip_mpfs_icicle_defconfig
cp -v ./u-boot/defconfig ./patches/u-boot/beaglev-fire/microchip_mpfs_icicle_defconfig

echo "make -C u-boot -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} all"
make -C u-boot -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} all

cp -v ./u-boot/u-boot.bin ./deploy/
cp -v ./u-boot/u-boot.bin ./deploy/src.bin

#
