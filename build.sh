#!/bin/sh
if [ ! -e arm-pocketbook-linux-gnueabi ]; then
	ct-ng build || exit 1
fi
export PATH=$(pwd)/arm-pocketbook-linux-gnueabi/bin:$PATH
make release
