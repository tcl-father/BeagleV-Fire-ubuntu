#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)
wdir=`pwd`
CC=${CC:-"${wdir}/riscv-toolchain/bin/riscv64-linux-"}

make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} distclean

cd ./u-boot/
#cp -v include/configs/microchip_mpfs_icicle.h ../patches/u-boot/original/
#cp -v arch/riscv/dts/microchip-mpfs-icicle-kit.dts ../patches/u-boot/original/
#cp -v configs/microchip_mpfs_icicle_defconfig ../patches/u-boot/original/
#exit 2

cp -v ../patches/u-boot/beaglev-fire/microchip_mpfs_icicle.h include/configs/microchip_mpfs_icicle.h
cp -v ../patches/u-boot/beaglev-fire/microchip-mpfs-icicle-kit.dts arch/riscv/dts/
cp -v ../patches/u-boot/beaglev-fire/microchip_mpfs_icicle_defconfig configs/microchip_mpfs_icicle_defconfig
cd ../

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
