#!/bin/bash

make -C hart-software-services/tools/hss-payload-generator/ clean
echo "make -C hart-software-services/tools/hss-payload-generator/"
make -C hart-software-services/tools/hss-payload-generator/

cp -v ./hart-software-services/tools/hss-payload-generator/hss-payload-generator ./deploy/
