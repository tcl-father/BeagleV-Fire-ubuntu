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

#
# Scheduler features
#
# end of Scheduler features

./scripts/config --enable CONFIG_MEMCG
./scripts/config --enable CONFIG_MEMCG_KMEM
./scripts/config --enable CONFIG_CGROUP_HUGETLB

./scripts/config --set-str CONFIG_CMDLINE ""
./scripts/config --disable CONFIG_CMDLINE_FALLBACK
./scripts/config --enable CONFIG_EEPROM_AT24
./scripts/config --enable CONFIG_OF_OVERLAY
./scripts/config --enable CONFIG_GPIO_MICROCHIP_CORE
./scripts/config --enable CONFIG_MCP356X
./scripts/config --enable CONFIG_POLARFIRE_SOC_GENERIC_SERVICE

#
# Networking options
#
./scripts/config --disable CONFIG_NETLABEL

#
# File systems
#
./scripts/config --enable CONFIG_EXT4_FS_SECURITY
./scripts/config --disable CONFIG_FANOTIFY
./scripts/config --enable CONFIG_AUTOFS_FS

#
# DOS/FAT/EXFAT/NT Filesystems
#
./scripts/config --enable CONFIG_FAT_FS
./scripts/config --enable CONFIG_MSDOS_FS
./scripts/config --enable CONFIG_VFAT_FS

#
# Pseudo filesystems
#
./scripts/config --enable CONFIG_PROC_CHILDREN
./scripts/config --enable CONFIG_HUGETLBFS
./scripts/config --enable CONFIG_NLS_CODEPAGE_437

#
# Security options
#
./scripts/config --enable CONFIG_SECURITY
./scripts/config --enable CONFIG_SECURITYFS
./scripts/config --enable CONFIG_SECURITY_NETWORK
./scripts/config --enable CONFIG_SECURITY_PATH
./scripts/config --set-val CONFIG_LSM_MMAP_MIN_ADDR 65536

./scripts/config --disable CONFIG_SECURITY_SELINUX
./scripts/config --disable CONFIG_SECURITY_SMACK
./scripts/config --disable CONFIG_SECURITY_TOMOYO
./scripts/config --disable CONFIG_SECURITY_APPARMOR
./scripts/config --disable CONFIG_SECURITY_LOADPIN
./scripts/config --disable CONFIG_SECURITY_YAMA
./scripts/config --disable CONFIG_SECURITY_SAFESETID
./scripts/config --disable CONFIG_SECURITY_LOCKDOWN_LSM
./scripts/config --disable CONFIG_SECURITY_LANDLOCK

./scripts/config --enable CONFIG_INTEGRITY
./scripts/config --disable CONFIG_INTEGRITY_SIGNATURE

./scripts/config --disable CONFIG_IMA
./scripts/config --disable CONFIG_EVM

echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} Image modules dtbs"
make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} Image modules dtbs

KERNEL_UTS=$(cat "${wdir}/linux/include/generated/utsrelease.h" | awk '{print $3}' | sed 's/\"//g' )

if [ -d "${wdir}/deploy/tmp/" ] ; then
	rm -rf "${wdir}/deploy/tmp/"
fi
mkdir -p "${wdir}/deploy/tmp/"

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
if [ ! -d ../deploy/input/ ] ; then
	mkdir -p ../deploy/input/ || true
fi
cp -v ./arch/riscv/boot/Image ../deploy/input/
cp -v ./arch/riscv/boot/dts/microchip/mpfs-beaglev-fire.dtb ../deploy/input/

cd ../

#
