#!/bin/bash

cd ./deploy/
if [ ! -d ./root/ ] ; then
	mkdir ./root/ || true
fi
sudo genimage --config genimage.cfg
