#!/system/bin/sh

# Different linux rootfs archives from linuxcontainers.org install script.

set -e

###
show_usage() {
echo 'Usage:'
echo "  $0 [-a] [-d] [-e] [--] <distro> <release> [<target_subdir_name>]"
echo '    -a -- non-interactive mode'
echo '    -d -- do not use minitar and PRoot from a plugin if present'
echo '    -e -- fail if no minitar or PRoot from a plugin are present'
echo
echo 'Variables:'
echo '  REG_USER - user account name; default:' "$REG_USER"
echo '  FAV_SHELL - preferable shell; default:' "$FAV_SHELL" '(fallback: /bin/sh)'
echo '  PROOT - proot location; default: <auto>'
echo '  PROOT_USERLAND - proot userland flavor location; default: <auto>'
echo '  ESSENTIALS_PKG - Application ID of a minitar and PRoot plugin to check; default:' "$ESSENTIALS"
echo '  ROOTFS_URL - override root FS source URL'
}
###

# We can't simply use `()' to introduce a newly exported TMPDIR to the shell in Android 10.
_TMPDIR="$DATA_DIR/tmp"
if [ "$_TMPDIR" != "$TMPDIR" ] ; then
export TMPDIR="$_TMPDIR"
mkdir -p "$TMPDIR"
/system/bin/sh "$0" "$@"
exit "$?"
fi
export TMPDIR
mkdir -p "$TMPDIR"

trap 'exit 1' INT HUP QUIT TERM ALRM USR1

TERMSH="$LIB_DIR/libtermsh.so"

exit_with() {
echo "$@" >&2
exit 1
}

# === Locale ===
if [ -z "$LANG" ] ; then
  export LANG='en_US.UTF-8'
else
  case "$LANG" in
    *.utf*|*.UTF*) ;;
    *) export LANG="${LANG%.*}.UTF-8" ;;
  esac
fi
# ===        ===

NI= # Non-interactive
UP= # Essentials plugin: force / no
while true ; do
case "$1" in
--) shift ; break ;;
-a) shift ; NI=1 ;;
-d) shift ; UP='no' ;;
-e) shift ; UP='force' ;;
-*) exit_with "Bad argument: $1" ;;
*) break ;;
esac
done

DISTRO="$1"
RELEASE="$2"
NAME="${3:-"linuxcontainers-$DISTRO-$RELEASE"}"
REG_USER="${REG_USER:-my_acct}"
FAV_SHELL="${FAV_SHELL:-/bin/bash}"
PROOT="${PROOT:-'$DATA_DIR/root/bin/proot'}"
PROOT_USERLAND="${PROOT:-'$DATA_DIR/root/bin/proot-userland'}"
ESSENTIALS="${ESSENTIALS_PKG:-green_green_avk.anothertermshellplugin_android10essentials}"

if [ -z "$1" -o -z "$2" ] ; then
show_usage
exit 1
fi

find_prefix() { # Old Androids have no `grep'.
local L
while read -r L ; do
case $L in
$1*) echo "$L" ; return 0 ;;
esac
done
return 1
}

prompt() {
echo -en "\e[1m$1 [\e[0m$2\e[1m]:\e[0m "
local _V
read _V
_V="${_V:-"$2"}"
eval "$3=${_V@Q}" # Default shell can't `typeset -g' before Android 8.
}

to_uname_arch() {
case "$1" in
armeabi-v7a) echo armv7a ;;
arm64-v8a) echo aarch64 ;;
x86) echo i686 ;;
amd64) echo x86_64 ;;
*) echo "$1" ;;
esac
}

validate_arch() {
case "$1" in
armv7a|aarch64|i686|amd64) echo $1 ; return 0 ;;
*) return 1 ;;
esac
}

validate_dir() { [ -d "$1" -a -r "$1" -a -w "$1" -a -x "$1" ] ; }

PROOTS='proots'

if [ -z "$NI" ] ; then
NAME="linuxcontainers-$DISTRO-$RELEASE"
echo
prompt "Installation subdir name $PROOTS/___" "$NAME" NAME
fi

mkdir -p "$DATA_DIR/$PROOTS"
if ! validate_dir "$DATA_DIR/$PROOTS" ; then
echo -e "\nUnable to create \$DATA_DIR/$PROOTS"
exit 1
fi

NAME_C=1
NAME_S=
NAME_B="$NAME"
while true ; do
NAME="$NAME_B$NAME_S"
ROOTFS_DIR="$PROOTS/$NAME"
if mkdir "$DATA_DIR/$ROOTFS_DIR" >/dev/null 2>&1 ; then break ; fi
if [ "$NAME_C" -gt 100 ] ; then
echo -e '\nSuspiciously many rootfses installed'
exit 1
fi
NAME_C="$(($NAME_C+1))"
NAME_S="-$NAME_C"
done

echo -e "\nActual name: $NAME\n"
echo -e "To uninstall: run \`rm -rf \"\$DATA_DIR/$ROOTFS_DIR\"'\n"

MINITAR="$DATA_DIR/minitar"


echo 'Creating favorites...'

echo -e '#!/system/bin/sh\n\necho Installing... Try later.' > "$DATA_DIR/$ROOTFS_DIR/run"
chmod 755 "$DATA_DIR/$ROOTFS_DIR/run"

case "$DISTRO" in
alpine) RUN_OPTS_TERM='xterm-xfree86' ;;
*) RUN_OPTS_TERM='' ;;
esac

RUN="/system/bin/sh \"\$DATA_DIR/$ROOTFS_DIR/run\""

if [ -z "$NI" ] ; then

if [ -n "$RUN_OPTS_TERM" ] ; then
RUN_OPTS="&terminal_string=$RUN_OPTS_TERM"
else
RUN_OPTS=''
fi
UE_RUN="$("$TERMSH" uri-encode "$RUN")"
"$TERMSH" view \
-r 'green_green_avk.anotherterm.FavoriteEditorActivity' \
-u "local-terminal:/opts?execute=${UE_RUN}%200%3A0&name=$("$TERMSH" uri-encode "$NAME (root)")$RUN_OPTS"
"$TERMSH" view \
-r 'green_green_avk.anotherterm.FavoriteEditorActivity' \
-u "local-terminal:/opts?execute=${UE_RUN}&name=$("$TERMSH" uri-encode "$NAME")$RUN_OPTS"

else

"$TERMSH" request-permission favmgmt 'Installer is going to create a regular user and a root launching favs.' \
&& {
finally() { "$TERMSH" revoke-permission favmgmt ; trap - EXIT ; unset finally ; }
trap 'finally' EXIT
} || [ $? -eq 3 ]
if [ -n "$RUN_OPTS_TERM" ] ; then
RUN_OPTS=(-t "$RUN_OPTS_TERM")
else
RUN_OPTS=()
fi
"$TERMSH" create-shell-favorite "${RUN_OPTS[@]}" "$NAME (root)" "$RUN 0:0" > /dev/null
"$TERMSH" create-shell-favorite "${RUN_OPTS[@]}" "$NAME" "$RUN" > /dev/null
if typeset -f finally >/dev/null 2>&1 ; then finally ; fi

fi

echo 'Done.'


# There is no uname on old Androids.
ARCH="$(validate_arch "$(uname -m 2>/dev/null)" || ( aa=($MY_DEVICE_ABIS) ; to_uname_arch "${aa[0]}" ))"

VARIANT=''
if [ -n "$MY_ANDROID_SDK" -a "$MY_ANDROID_SDK" -lt 21 ]
then
VARIANT='-pre5'
fi

to_minitar_arch() {
case "$1" in
armv7a) echo armeabi-v7a ;;
aarch64) echo arm64-v8a ;;
i686) echo x86 ;;
amd64) echo x86_64 ;;
*) echo "$1" ;;
esac
}

to_lco_arch() {
case "$1" in
armv7a) echo armhf ;;
aarch64) echo arm64 ;;
i686) echo i386 ;;
x86_64) echo amd64 ;;
*) echo "$1" ;;
esac
}

to_lco_link() {
local R
local P
R="$( { "$TERMSH" cat 'https://images.linuxcontainers.org/meta/1.0/index-user' || exit_with 'Cannot download index from linuxcontainers.org' ;} \
| { find_prefix "$DISTRO;$RELEASE;$(to_lco_arch "$1");default;" || exit_with 'Cannot find specified rootfs' ;} )" || exit 1
P="${R##*;}"
echo "https://images.linuxcontainers.org/$P/rootfs.tar.xz"
}

echo
echo "Arch: $ARCH"
echo "Variant: $VARIANT"
echo "Root FS: $DISTRO $RELEASE"
echo

if [ -z "$ROOTFS_URL" ] ; then
ROOTFS_URL="$(to_lco_link "$ARCH")"
fi

echo "Source: $ROOTFS_URL"
echo

cd "$DATA_DIR"
(

OO="$([ -t 2 ] && echo --progress)"


# = Essentials =
if [ "$UP" != 'no' ] && E_MINITAR="$("$TERMSH" plugin "$ESSENTIALS" minitar)" 2>/dev/null
then MINITAR="$E_MINITAR"
elif [ "$UP" = 'force' ]
then exit_with 'No minitar in the essentials plugin found'
# ==============
else

echo 'Getting minitar...'

"$TERMSH" cat $OO \
"https://raw.githubusercontent.com/green-green-avk/build-libarchive-minitar-android/master/prebuilt/$(to_minitar_arch "$ARCH")/minitar" \
> "$MINITAR"
chmod 755 "$MINITAR"

fi


# = Essentials =
if [ "$UP" != 'no' ] && E_PROOT="$("$TERMSH" plugin "$ESSENTIALS" proot)" 2>/dev/null
then
PROOT="\$(\"\$TERMSH\" plugin '$ESSENTIALS' proot)"
PROOT_USERLAND="\$(\"\$TERMSH\" plugin '$ESSENTIALS' proot-userland)" || true
elif [ "$UP" = 'force' ]
then exit_with 'No proot in the essentials plugin found'
# ==============
else

echo 'Getting PRoot...'

"$TERMSH" cat $OO \
"https://raw.githubusercontent.com/green-green-avk/build-proot-android/master/packages/proot-android-$ARCH$VARIANT.tar.gz" \
| "$MINITAR"

fi


# = Test =
[ -n "$MY_ANDROID_SDK" -a "$MY_ANDROID_SDK" -ge 29 \
-a -n "$APP_TARGET_SDK" -a "$APP_TARGET_SDK" -ge 29 ] \
&& { eval "$PROOT" --help > /dev/null 2>&1 || \
exit_with "$(
echo 'Current PRoot version does not start.'
echo "Your Android version is 10 (API 29) or higher and this Another Term version targets API $APP_TARGET_SDK."
echo 'See https://green-green-avk.github.io/AnotherTerm-docs/local-shell-w-x.html#main_content'
)" ; } || true
# ========


mkdir -p "$ROOTFS_DIR/root"
mkdir -p "$ROOTFS_DIR/tmp"
cd "$ROOTFS_DIR/root"


echo 'Getting Linux root FS...'

"$TERMSH" cat $OO "$ROOTFS_URL" | "$MINITAR" || echo 'Possibly URL was changed: recheck on the site.' >&2


if [ -z "$NI" ] ; then
echo
echo -e '\e[1m/etc/passwd:\e[0m'
echo '\e[1m=======\e[0m'
cat etc/passwd
echo '\e[1m=======\e[0m'
prompt 'Regular user name' "$REG_USER" REG_USER
prompt 'Preferred shell' "$FAV_SHELL" FAV_SHELL
echo
fi


echo 'Setting up run script...'

mkdir -p etc/proot
cat << EOF > etc/proot/run.cfg
# Main configuration

# Regular user name
USER=${REG_USER@Q}

# Preferred shell (fallback: /bin/sh)
SHELL=${FAV_SHELL@Q}

# =======

PROOT=$PROOT
PROOT_USERLAND=$PROOT_USERLAND

# Mostly for Android < 5 now. Feel free to adjust.
# Not recommended to set it >= '4.8.0' for kernels < '4.8.0'
# becouse of a random number generation API change at this point
# as it could break libopenssl random number generation routine.
_KERNEL_VERSION="$(uname -r 2>/dev/null || echo 0)"
if [ "\${_KERNEL_VERSION%%.*}" -lt 4 ] ; then
 PROOT_OPT_ARGS+=('-k' '4.0.0')
fi

# Android >= 9 can have a read restictiction
# on '/proc/version'.
cat /proc/version >/dev/null 2>&1 || {
 _PROC_VERSION="\$CFG_DIR/proc.version.cfg"
 { uname -a 2>/dev/null || echo 'Linux' ; } > "\$_PROC_VERSION"
 PROOT_OPT_ARGS+=('-b' "\$_PROC_VERSION:/proc/version")
}

# Application data shared directory.
PROOT_OPT_ARGS+=('-b' "\$SHARED_DATA_DIR:/mnt/shared")

# Uncomment to manipulate Android application own private data directory.
#PROOT_OPT_ARGS+=('-b' '/data')

# =======
EOF
cat << EOF > etc/proot/run.rc
# Right before proot starting

if ! is_root
then
 PROOT_OPT_ARGS+=('--mute-setxid') # 'make' should be happy now...
fi
EOF
"$TERMSH" cat $OO \
'https://raw.githubusercontent.com/green-green-avk/AnotherTerm-scripts/master/assets/run-tpl' \
> etc/proot/run
chmod 755 etc/proot/run
rm -r ../run 2>/dev/null || true # Jelly Bean has no `-f' option (API 16 at least).
ln -s root/etc/proot/run ../run # KitKat can only `ln -s'.


echo 'Configuring...'

cat << EOF > bin/termsh
#!/bin/sh

unset LD_PRELOAD
unset LD_LIBRARY_PATH
/bin/_termsh "\$@"
EOF

chmod 700 bin/termsh

rm -r etc/resolv.conf 2>/dev/null || true # Ubuntu Focal
cat << EOF > etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

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

# We have no adduser or useradd here...
cp -a etc/skel home/$REG_USER 2>/dev/null || mkdir -p home/$REG_USER
echo \
"$REG_USER:x:$USER_ID:$USER_ID:guest:/home/$REG_USER:$FAV_SHELL" \
>> etc/passwd
)


echo -e '\nDone!\n'
