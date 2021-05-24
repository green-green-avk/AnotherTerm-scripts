#!/bin/bash

# =======
# libandroid-shmem ashmem wrapper for chrooted environments build script
# =======

# Enjoy any software dynamically linked to the System V shared memory API
# without rooting your Android device.

# Targeted for any distro with **apt**, **apk** and **yum** at the moment.
# To be tested...

# Warning:
# It will not work on Android 10
# with anything that targets Android 10.
# See https://developer.android.com/about/versions/10/behavior-changes-10#shared-memory
# Another Term flavors:
# * Default (Google Play) and `.redist` - target Android 10;
# * `.oldgood` - targets Android 9.
#
# Resolved in
# https://github.com/green-green-avk/AnotherTerm-scripts/blob/master/install-libwrapdroid.sh

set -e

if [ $(id -u) -ne 0 ]
then
echo 'Should be run as root!' >&2
exit 1
fi

(
which apt-get >/dev/null 2>&1 && {
apt-get install wget binutils gcc make patch
exit 0
}
which apk >/dev/null 2>&1 && {
apk add linux-headers wget binutils gcc make patch
exit 0
}
which yum >/dev/null 2>&1 && {
yum install wget binutils gcc make patch
exit 0
}
echo 'No idea about your distribution...'
echo 'Presuming prerequisites are already installed.'
exit 0
)

mkdir -p build
cd build
PKG_NAME='libandroid-shmem-0.3'
wget -O - 'https://github.com/termux/libandroid-shmem/archive/refs/tags/v0.3.tar.gz' | tar -zxv
cd "$PKG_NAME"

wget -O - 'https://raw.githubusercontent.com/green-green-avk/libandroid-shmem-chrooted-patch/main/libandroid-shmem-0.3-chrooted.patch' | patch -p1

make 'libandroid-shmem.so'

install -D 'libandroid-shmem.so' '/opt/shm/lib/libandroid-shmem.so'

echo 'To use:'
echo 'Just set your LD_PRELOAD when required similar to:'
echo 'export LD_PRELOAD="/opt/shm/lib/libandroid-shmem.so${LD_PRELOAD:+:$LD_PRELOAD}"'
echo
echo 'Enjoy!'
