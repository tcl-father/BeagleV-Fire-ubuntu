#!/bin/bash

cd ./deploy/
./hss-payload-generator -c config.yaml -v ./input/payload.bin
sha256sum ./input/payload.bin

#
