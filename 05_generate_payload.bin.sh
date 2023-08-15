#!/bin/bash

cd ./deploy/

if [ -f ./src.bin ] ; then
	if [ ! -d ./input/ ] ; then
		mkdir ./input/
	fi

	if [ -f ./input/payload.bin ] ; then
		rm -rf ./input/payload.bin || true
	fi

	./hss-payload-generator -vv -c config.yaml ./input/payload.bin

	date
	unset test_var
	test_var=$(strings ./u-boot.bin | grep 'U-Boot 20' | head -n1 || true)
	if [ ! "x${test_var}" = "x" ] ; then
		echo "[u-boot.bin: ${test_var}]"
	fi

	unset test_var
	test_var=$(strings ./src.bin | grep 'U-Boot 20' | head -n1 || true)
	if [ ! "x${test_var}" = "x" ] ; then
		echo "[src.bin:    ${test_var}]"
	fi

	unset test_var
	test_var=$(strings ./input/payload.bin | grep 'U-Boot 20' | head -n1 || true)
	if [ ! "x${test_var}" = "x" ] ; then
		echo "[payload.bin:${test_var}]"
	fi
fi

#
