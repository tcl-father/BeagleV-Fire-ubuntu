#!/bin/bash

if ! id | grep -q root; then
	echo "./07_create_sdcard_img.sh must be run as root:"
	echo "sudo ./07_create_sdcard_img.sh"
	exit
fi

cd ./deploy/
if [ ! -d ./root/ ] ; then
	mkdir ./root/ || true
fi

if [ -d ./tmp ] ; then
	rm -rf ./tmp || true
fi

if [ -f ./images/sdcard.img ] ; then
	rm -rf ./images/sdcard.img || true
fi

genimage --config genimage.cfg

if [ -d ./tmp ] ; then
	rm -rf ./tmp || true
fi

if [ -f /usr/bin/bmaptool ] ; then
	if [ -f ./images/sdcard.bmap ] ; then
		rm -rf ./images/sdcard.bmap || true
	fi
	/usr/bin/bmaptool -d create -o ./images/sdcard.bmap ./images/sdcard.img
fi

#
