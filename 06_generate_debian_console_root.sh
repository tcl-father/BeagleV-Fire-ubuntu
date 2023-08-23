#!/bin/bash

if ! id | grep -q root; then
	echo "./06_generate_debian_console_root.sh must be run as root:"
	echo "sudo ./06_generate_debian_console_root.sh"
	exit
fi

wdir=`pwd`

if [ -f /tmp/latest ] ; then
	rm -rf /tmp/latest | true
fi
wget --quiet --directory-prefix=/tmp/ https://rcn-ee.net/rootfs/debian-riscv64-sid-minimal/latest || true
if [ -f /tmp/latest ] ; then
	latest_rootfs=$(cat "/tmp/latest")
	datestamp=$(cat "/tmp/latest" | awk -F 'riscv64-' '{print $2}' | awk -F '.' '{print $1}')

	if [ ! -f ./deploy/debian-sid-console-riscv64-${datestamp}/riscv64-rootfs-debian-sid.tar ] ; then
		wget -c --directory-prefix=./deploy https://rcn-ee.net/rootfs/debian-riscv64-sid-minimal/${datestamp}/${latest_rootfs}
		cd ./deploy/
		tar xf ${latest_rootfs}
		cd ../
	fi
else
	echo "Failure: getting image"
	exit 2
fi

if [ -d ./ignore/.root ] ; then
	rm -rf ./ignore/.root || true
fi
mkdir -p ./ignore/.root

echo "Extracting: debian-sid-console-riscv64-${datestamp}/riscv64-rootfs-*.tar"
tar xfp ./deploy/debian-sid-console-riscv64-${datestamp}/riscv64-rootfs-*.tar -C ./ignore/.root
sync

mkdir -p ./deploy/input/ || true
echo "label Linux eMMC" > ./deploy/input/extlinux.conf
echo "    kernel /Image" >> ./deploy/input/extlinux.conf
echo "    append root=/dev/mmcblk0p3 ro rootfstype=ext4 rootwait console=ttyS0,115200 earlycon uio_pdrv_genirq.of_id=generic-uio net.ifnames=0" >> ./deploy/input/extlinux.conf
echo "    fdtdir /" >> ./deploy/input/extlinux.conf
echo "    fdt /mpfs-beaglev-fire.dtb" >> ./deploy/input/extlinux.conf
echo "    #fdtoverlays /overlays/<file>.dtbo" >> ./deploy/input/extlinux.conf

echo "extlinux/extlinux.conf"
cat ./deploy/input/extlinux.conf

mkdir -p ./ignore/.root/boot/firmware/ || true

echo '/dev/mmcblk0p2  /boot/firmware/ auto  defaults  0  2' >> ./ignore/.root/etc/fstab
echo '/dev/mmcblk0p3  /  auto  errors=remount-ro  0  1' >> ./ignore/.root/etc/fstab
echo 'debugfs  /sys/kernel/debug  debugfs  mode=755,uid=root,gid=gpio,defaults  0  0' >> ./ignore/.root/etc/fstab

rm -rf ./ignore/.root/usr/lib/systemd/system/bb-usb-gadgets.service || true
rm -rf ./ignore/.root/etc/systemd/system/getty.target.wants/serial-getty@ttyGS0.service || true
rm -rf ./ignore/.root/etc/systemd/network/usb0.network || true
rm -rf ./ignore/.root/etc/systemd/network/usb1.network || true

cp -v ./ignore/.root/etc/bbb.io/templates/eth0-DHCP.network ./ignore/.root/etc/systemd/network/eth0.network || true

if [ -f ./ignore/.root/etc/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service ] ; then
	rm -rf ./ignore/.root/etc/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service || true
fi

#rm -rf ./ignore/.root/usr/lib/systemd/system/grow_partition.service || true
#cd ./ignore/.root/
#ln -L -f -s -v /lib/systemd/system/resize_filesystem.service --target-directory=./etc/systemd/system/multi-user.target.wants/
#cd ../../

# setuid root ping+ping6
chmod u+s ./ignore/.root/usr/bin/ping ./ignore/.root/usr/bin/ping6

if [ -f ./deploy/.modules ] ; then
	version=$(cat ./deploy/.modules || true)
	if [ -f ./deploy/${version}-modules.tar.gz ] ; then
		tar xf ./deploy/${version}-modules.tar.gz -C ./ignore/.root/usr/
	fi
fi

echo '---------------------'
echo 'File Size'
du -sh ignore/.root/ || true
echo '---------------------'

dd if=/dev/zero of=./deploy/input/root.ext4 bs=1 count=0 seek=2200M
mkfs.ext4 -F ./deploy/input/root.ext4 -d ./ignore/.root

if [ -f ./.06_generate_root.sh ] ; then
	rm -f ./.06_generate_root.sh || true
fi
