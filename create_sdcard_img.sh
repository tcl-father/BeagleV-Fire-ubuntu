#!/bin/bash

if ! id | grep -q root; then
	echo "./create_sdcard_img.sh must be run as root:"
	echo "sudo ./create_sdcard_img.sh"
	exit
fi

cd ./deploy/
if [ ! -d ./root/ ] ; then
	mkdir ./root/ || true
fi

if [ -d ./tmp ] ; then
	rm -rf ./tmp || true
fi

genimage --config genimage.cfg

#
