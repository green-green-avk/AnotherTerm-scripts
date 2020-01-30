#!/bin/bash

# =======
# Another Term libusb wrapper build script
# =======

# Enjoy any software dynamically linked to the libusb without rooting your Android device.

# Targeted for any distro with apt and apk repositories at the moment.
# Tested with Debian only yet.

set -e

if [ $(id -u) -ne 0 ]
then
echo 'Should be run as root!' >&2
exit 1
fi

{
which apt-get >/dev/null 2>&1 && {
apt-get install git binutils gcc g++ make m4 autoconf automake libtool gettext
return
}
which apk >/dev/null 2>&1 && {
apk add git binutils gcc g++ make m4 autoconf automake libtool gettext usbutils
return
}
}

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

echo 'The libusb wrapper will work in newly started sessions. Enjoy!'
