#!/system/bin/sh

# Debian Buster from linuxcontainers.org install script.

PROOTS=proots
NAME=linuxcontainers-deb
ROOTFS_DIR="$PROOTS/$NAME"
ARCH=$(uname -m) # Possibly there is no uname on old Androids.
MINITAR="$DATA_DIR/minitar"

export TMPDIR="$DATA_DIR/tmp"
mkdir -p "$TMPDIR"

to_minitar_arch() {
case $1 in
armv7a)
echo armeabi-v7a
;;
aarch64)
echo arm64-v8a
;;
i686)
echo x86
;;
amd64)
echo x86_64
;;
esac
}

to_arch_link() {
case $1 in
armv7a)
echo 'https://us.images.linuxcontainers.org/images/debian/buster/armhf/default/20200127 05:24/rootfs.tar.xz'
;;
aarch64)
echo 'https://us.images.linuxcontainers.org/images/debian/buster/arm64/default/20200127_05:32/rootfs.tar.xz'
;;
i686)
echo 'https://us.images.linuxcontainers.org/images/debian/buster/i386/default/20200127 05:24/rootfs.tar.xz'
;;
amd64)
echo 'https://us.images.linuxcontainers.org/images/debian/buster/amd64/default/20200127 05:50/rootfs.tar.xz'
;;
esac
}

cd "$DATA_DIR"
(
echo 'Getting minitar...'
"$TERMSH" cat \
"https://github.com/green-green-avk/build-libarchive-minitar-android/raw/master/prebuilt/$(to_minitar_arch $ARCH)/minitar" \
> "$MINITAR"
chmod 755 "$MINITAR"
echo 'Getting PRoot...'
"$TERMSH" cat \
"https://github.com/green-green-avk/build-proot-android/raw/master/packages/proot-android-$ARCH.tar.gz" \
| "$MINITAR"
mkdir -p "$ROOTFS_DIR/root"
mkdir -p "$ROOTFS_DIR/tmp"
cd "$ROOTFS_DIR/root"
echo 'Getting Debian...'
"$TERMSH" cat \
"$(to_arch_link $ARCH)" \
| "$MINITAR"
echo 'Setting up run script...'
mkdir -p etc/proot
"$TERMSH" cat https://github.com/green-green-avk/proot/raw/master/doc/usage/android/start-script-example > etc/proot/run
chmod 755 etc/proot/run
ln -snf root/etc/proot/run ../run
echo 'Configuring...'
cat << EOF > etc/resolv.conf
search local
nameserver 192.168.0.1
nameserver 208.67.220.220
nameserver 208.67.222.222
EOF
echo 'Creating favorite...'
"$TERMSH" view -r 'green_green_avk.anotherterm.FavoriteEditorActivity' \
-u "local_terminal:/opts?execute=%24DATA_DIR%2F${ROOTFS_DIR/\//%2F}%2Frun%200%3A0&name=$NAME%20(root)"
echo 'Done'
)
