#!/bin/bash

HSS_BRANCH="v2023.02"
HSS_REPO="https://github.com/polarfire-soc/hart-software-services.git"

#UBOOT_BRANCH="mpfs-uboot-2022.01"
UBOOT_BRANCH="linux4microchip+fpga-2023.02"
UBOOT_REPO="https://github.com/polarfire-soc/u-boot.git"

#LINUX_BRANCH="linux4microchip+fpga-2023.06"
#LINUX_REPO="https://github.com/linux4microchip/linux.git"

LINUX_BRANCH="master"
LINUX_REPO="https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"

GIT_DEPTH="20"

if [ ! -f ./mirror/x86_64-gcc-11.4.0-nolibc-riscv64-linux.tar.xz ] ; then
	echo "wget -c --directory-prefix=./mirror/ https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/11.4.0/x86_64-gcc-11.4.0-nolibc-riscv64-linux.tar.xz"
	wget -c --directory-prefix=./mirror/ https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/11.4.0/x86_64-gcc-11.4.0-nolibc-riscv64-linux.tar.xz
fi

if [ ! -f ./riscv-toolchain/bin/riscv64-linux-gcc-11.4.0 ] ; then
	echo "tar xf ./mirror/x86_64-gcc-11.4.0-nolibc-riscv64-linux.tar.xz --strip-components=2 -C ./riscv-toolchain/"
	tar xf ./mirror/x86_64-gcc-11.4.0-nolibc-riscv64-linux.tar.xz --strip-components=2 -C ./riscv-toolchain/
fi

#if [ ! -f ./mirror/x86_64-gcc-13.2.0-nolibc-riscv64-linux.tar.xz ] ; then
#	echo "wget -c --directory-prefix=./mirror/ https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/13.2.0/x86_64-gcc-13.2.0-nolibc-riscv64-linux.tar.xz"
#	wget -c --directory-prefix=./mirror/ https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/13.2.0/x86_64-gcc-13.2.0-nolibc-riscv64-linux.tar.xz
#fi

#if [ ! -f ./riscv-toolchain/bin/riscv64-linux-gcc-13.2.0 ] ; then
#	echo "tar xf ./mirror/x86_64-gcc-13.2.0-nolibc-riscv64-linux.tar.xz --strip-components=2 -C ./riscv-toolchain/"
#	tar xf ./mirror/x86_64-gcc-13.2.0-nolibc-riscv64-linux.tar.xz --strip-components=2 -C ./riscv-toolchain/
#fi

#if [ -d ./hart-software-services/ ] ; then
#	rm -rf ./hart-software-services/ || true
#fi

#echo "git clone -b ${HSS_BRANCH} ${HSS_REPO} ./hart-software-services/ --depth=${GIT_DEPTH}"
#git clone -b ${HSS_BRANCH} ${HSS_REPO} ./hart-software-services/ --depth=${GIT_DEPTH}

#if [ -d ./u-boot ] ; then
#	rm -rf ./u-boot || true
#fi

#echo "git clone -b ${UBOOT_BRANCH} ${UBOOT_REPO} ./u-boot/ --depth=${GIT_DEPTH}"
#git clone -b ${UBOOT_BRANCH} ${UBOOT_REPO} ./u-boot/ --depth=${GIT_DEPTH}

if [ -d ./linux ] ; then
	rm -rf ./linux || true
fi

echo "git clone -b ${LINUX_BRANCH} ${LINUX_REPO} ./linux/ --depth=${GIT_DEPTH}"
git clone -b ${LINUX_BRANCH} ${LINUX_REPO} ./linux/ --depth=${GIT_DEPTH}

#
