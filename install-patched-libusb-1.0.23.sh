#!/bin/bash

# Targeted for any distro with apt repositories at the moment.
# Tested with Debian only yet.

set -e

if [ $(id -u) -ne 0 ]
then
echo 'Should be run as root!' >&2
exit 1
fi

apt-get install git binutils gcc g++ make m4 autoconf automake libtool gettext

mkdir -p build
cd build
PKG_NAME=libusb-1.0.23-android-helper-service-patch
git clone "https://github.com/green-green-avk/$PKG_NAME"
cd "$PKG_NAME"

./bootstrap.sh
./configure --prefix=/opt/libusb --enable-android-helper=$APP_ID.libusb
make && make install

echo 'Setting up LD_LIBRARY_PATH...'
echo 'export LD_LIBRARY_PATH="/opt/libusb/lib:$LD_LIBRARY_PATH"' > /etc/profile.d/libusb.sh
echo 'Done.'

echo 'libusb wrapper will work in new;y started sessions. Enjoy!'
