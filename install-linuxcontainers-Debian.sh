#!/system/bin/sh

# Debian Buster from linuxcontainers.org install script.

set -e

PROOTS=proots
NAME=linuxcontainers-deb
ROOTFS_DIR="$PROOTS/$NAME"
# There is no uname on old Androids.
ARCH=$(uname -m 2>/dev/null || ( aa=($("$TERMSH" arch)) ; echo "${aa[0]}" ))
echo "Arch: $ARCH"
MINITAR="$DATA_DIR/minitar"
REGULAR_USER_NAME=my_acct

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

# Be aware: URLs may change!
to_arch_link() {
case $1 in
armv7a)
echo 'https://us.images.linuxcontainers.org/images/debian/buster/armhf/default/20200130_05:41/rootfs.tar.xz'
;;
aarch64)
echo 'https://us.images.linuxcontainers.org/images/debian/buster/arm64/default/20200130_05:29/rootfs.tar.xz'
;;
i686)
echo 'https://us.images.linuxcontainers.org/images/debian/buster/i386/default/20200130_05:24/rootfs.tar.xz'
;;
amd64)
echo 'https://us.images.linuxcontainers.org/images/debian/buster/amd64/default/20200130_05:24/rootfs.tar.xz'
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
"$(to_arch_link $ARCH)" | "$MINITAR" || echo 'Possibly URL was changed: recheck on the site.' >&2
echo 'Setting up run script...'
mkdir -p etc/proot
"$TERMSH" cat \
'https://github.com/green-green-avk/proot/raw/master/doc/usage/android/start-script-example' \
> etc/proot/run
chmod 755 etc/proot/run
ln -snf root/etc/proot/run ../run
echo 'Configuring...'
cat << EOF > etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
# We have no adduser or useradd here...
cp -a etc/skel home/$REGULAR_USER_NAME
echo \
"$REGULAR_USER_NAME:x:$USER_ID:$USER_ID:guest:/home/$REGULAR_USER_NAME:/bin/bash" \
>> etc/passwd
cat << EOF > etc/profile.d/locale.sh
if [ -f /etc/default/locale ]
then
. /etc/default/locale
export LANG
fi
EOF
cat << EOF > etc/profile.d/ps.sh
PS1='\[\e[32m\]\u\[\e[33m\]@\[\e[32m\]\h\[\e[33m\]:\[\e[32m\]\w\[\e[33m\]\\$\[\e[0m\] '
PS2='\[\e[33m\]>\[\e[0m\] '
EOF
echo 'Creating favorites...'
"$TERMSH" view -N -r 'green_green_avk.anotherterm.FavoriteEditorActivity' \
-u "local_terminal:/opts?execute=%24DATA_DIR%2F${ROOTFS_DIR/\//%2F}%2Frun%200%3A0&name=$NAME%20(root)"
"$TERMSH" view -N -r 'green_green_avk.anotherterm.FavoriteEditorActivity' \
-u "local_terminal:/opts?execute=%24DATA_DIR%2F${ROOTFS_DIR/\//%2F}%2Frun&name=$NAME"
echo 'Done, see notifications.'
)
