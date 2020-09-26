This is an attempt to build fully open source pocketbook SDK with no binary blobs.

### Build instructions

1. Install @NiLuJe's fork of https://github.com/NiLuJe/crosstool-ng (needed to get support for ancient glibc versions)
2. git clone --recursive https://github.com/ezdiy/arm-pocketbook-linux-gnueabi
3. ct-ng build in it to build the gcc toolchain
3. ./build.sh in it to build the full SDK

The sdk is then in release/arm-pocketbook-linux-gnueabi.
