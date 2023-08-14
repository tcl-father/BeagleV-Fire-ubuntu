#!/bin/bash

cd ./deploy/
cp -v ./u-boot.bin ./src.bin
./hss-payload-generator -c config.yaml -v ./input/payload.bin
sha256sum ./input/payload.bin

#
