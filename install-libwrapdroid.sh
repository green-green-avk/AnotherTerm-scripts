#!/bin/bash

# =======
# libwrapdroid build script
# =======

# https://github.com/green-green-avk/libwrapdroid

# Enjoy any software dynamically linked to
# the System V and Posix shared memory APIs
# without rooting your Android device.

# Targeted for any distro with **apt**, **apk** and **yum** at the moment.
# To be tested...

set -e

if [ $(id -u) -ne 0 ]
then
echo 'It should be run as root!' >&2
echo '(Emulated by PRoot)' >&2
exit 1
fi

(
which apt-get >/dev/null 2>&1 && {
apt-get install git binutils gcc make
exit 0
}
which apk >/dev/null 2>&1 && {
apk add linux-headers git binutils gcc make
exit 0
}
which yum >/dev/null 2>&1 && {
yum install git binutils gcc make
exit 0
}
echo 'No idea about your distribution...'
echo 'Presuming prerequisites are already installed.'
exit 0
)

mkdir -p build
cd build
PKG_NAME='libwrapdroid'
git clone "https://github.com/green-green-avk/$PKG_NAME.git"
cd "$PKG_NAME"

make PREFIX=/opt/shm install

echo 'To use:'
echo 'Just set your environment variables when required similar to:'
echo -e 'export LIBWRAPDROID_SOCKET_NAME=\e[1m<some-socket-name>\e[0m'
echo -e 'export LIBWRAPDROID_AUTH_KEY=\e[1m<some-auth-key>\e[0m # not less than 16 hexidecimal digits'
echo 'export LD_PRELOAD="/opt/shm/lib/libwrapdroid-shm-sysv.so:/opt/shm/lib/libwrapdroid-shm-posix.so${LD_PRELOAD:+:$LD_PRELOAD}"'
echo 'and run /opt/shm/bin/libwrapdroid-server'
echo
echo 'Enjoy!'
