#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)
wdir=`pwd`
CC=${CC:-"${wdir}/riscv-toolchain/bin/riscv64-linux-"}

cd ./linux/

if [ ! -f ./.patched ] ; then
	patch -p1 < ../patches/linux/0001-Add-BeagleV-Fire-device-tree.patch
	patch -p1 < ../patches/linux/0001-PCIe-Change-controller-and-bridge-base-address.patch
	patch -p1 < ../patches/linux/0001-GPIO-Add-Microchip-CoreGPIO-driver.patch
	patch -p1 < ../patches/linux/0001-ADC-Add-Microchip-MCP356X-driver.patch
	patch -p1 < ../patches/linux/0001-Microchip-QSPI-Add-regular-transfers.patch
	patch -p1 < ../patches/linux/0001-BeagleV-Fire-Add-printk-to-IM219-driver-for-board-te.patch
	patch -p1 < ../patches/linux/0001-MMC-SPI-Hack-to-support-non-DMA-capable-SPI-ctrl.patch
	touch .patched
fi

cp -v ../patches/linux/Makefile arch/riscv/boot/dts/microchip/

make ARCH=riscv CROSS_COMPILE=${CC} clean
make ARCH=riscv CROSS_COMPILE=${CC} mpfs_defconfig

./scripts/config --enable CONFIG_OF_OVERLAY
./scripts/config --enable CONFIG_GPIO_MICROCHIP_CORE
./scripts/config --enable CONFIG_MCP356X

echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} Image modules dtbs"
make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} Image modules dtbs

KERNEL_UTS=$(cat "${wdir}/linux/include/generated/utsrelease.h" | awk '{print $3}' | sed 's/\"//g' )

make -s ARCH=riscv CROSS_COMPILE=${CC} modules_install INSTALL_MOD_PATH="${wdir}/deploy/tmp"

if [ -f "${wdir}/deploy/${KERNEL_UTS}-modules.tar.gz" ] ; then
	rm -rf "${wdir}/deploy/${KERNEL_UTS}-modules.tar.gz" || true
fi
echo "Compressing ${KERNEL_UTS}-modules.tar.gz..."
echo "${KERNEL_UTS}" > "${wdir}/deploy/.modules"
cd "${wdir}/deploy/tmp" || true
tar --create --gzip --file "../${KERNEL_UTS}-modules.tar.gz" ./*
cd "${wdir}/linux/" || exit
rm -rf "${wdir}/deploy/tmp" || true

cp -v ./.config ../patches/linux/mpfs_defconfig
cp -v ./arch/riscv/boot/Image ../deploy/
cp -v ./arch/riscv/boot/dts/microchip/mpfs-beaglev-fire.dtb ../deploy/

cd ../

