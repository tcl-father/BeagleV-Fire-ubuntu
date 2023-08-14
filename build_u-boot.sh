#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)
wdir=`pwd`
CC=${CC:-"${wdir}/riscv-toolchain/bin/riscv64-linux-"}

make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} distclean

cd ./u-boot/
#patch -p1 < ../patches/u-boot/0001-Use-MMUART0-for-stdout.patch
#exit 2
cp -v ../patches/u-boot/microchip-mpfs-icicle-kit.dts arch/riscv/dts/
cp -v ../patches/u-boot/uboot_smode_defconfig .config
cd ../

#make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} microchip_mpfs_icicle
#make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} olddefconfig
#make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} menuconfig
#make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} savedefconfig
#cp -v ./u-boot/defconfig ./u-boot/configs/microchip_mpfs_icicle_defconfig
#make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} distclean

make -C u-boot -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} olddefconfig
make -C u-boot ARCH=riscv CROSS_COMPILE=${CC} savedefconfig
cp -v ./u-boot/defconfig ./u-boot/configs/microchip_mpfs_icicle_defconfig

echo "make -C u-boot -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} all"
make -C u-boot -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} all

cp -v ./u-boot/u-boot.bin ./deploy/
cp -v ./u-boot/u-boot.bin ./deploy/src.bin

