#!/bin/bash

if ! id | grep -q root; then
	echo "must be run as root"
	exit
fi

if [ -f ./beaglev_fire.itb ] ; then
	rm -rf ./beaglev_fire.itb || true
fi

if [ -f ./modules.tar.gz ] ; then
	rm -rf ./modules.tar.gz || true
fi

wget https://beaglev-fire.beagleboard.io/BeagleV-Fire-ubuntu/beaglev_fire.itb
wget https://beaglev-fire.beagleboard.io/BeagleV-Fire-ubuntu/modules.tar.gz

if [ -f ./beaglev_fire.itb ] ; then
	if [ -d /boot/firmware/ ] ; then
	
		if [ -f /boot/firmware/beaglev_fire.itb ] ; then
			rm -rf /boot/firmware/beaglev_fire.itb || true
			cp -v ./beaglev_fire.itb /boot/firmware/beaglev_fire.itb
			sync
		fi
	fi
fi

if [ -f ./modules.tar.gz ] ; then
	tar xf ./modules.tar.gz -C /usr/
fi
