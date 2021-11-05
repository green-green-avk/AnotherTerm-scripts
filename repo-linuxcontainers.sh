#!/system/bin/sh

set -e

S_ESC="$(echo -en '\e')"
S_N="$(echo -en '\n')"
K_BACK='-2'

FD_I=8
FD_O=9
eval "exec $FD_I<&0"
eval "exec $FD_O>&1"

show_list() {
 local N=1
 for E in "$@" ; do
  if [ "$N" -lt 10 ] ; then echo -n ' ' >&$FD_O ; fi
  echo "$N. $E" >&$FD_O
  N=$((N+1))
 done
}

read_list_elt() {
 local N
 echo "Anything else - exit" >&$FD_O
 echo -n ': ' >&$FD_O
 read N >&$FD_O <&$FD_I
 if [ "$N" -gt 0 -a "$N" -le "$1" ] >/dev/null 2>&1 ; then
  echo $(($N-1))
  return 0
 fi
 echo "$K_BACK"
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

to_lco_arch() {
case "$1" in
armv7a) echo armhf ;;
aarch64) echo arm64 ;;
i686) echo i386 ;;
x86_64) echo amd64 ;;
*) echo "$1" ;;
esac
}

# There is no uname on old Androids.
U_ARCH="$(validate_arch "$(uname -m 2>/dev/null)" || ( aa=($MY_DEVICE_ABIS) ; to_uname_arch "${aa[0]}" ))"
R_ARCH="$(to_lco_arch "$U_ARCH")"

echo "$U_ARCH"

chooser() {
 TL=()
 PL=()
 DL=()
 RL=()

 while IFS=';' read -s -r DISTRO RELEASE ARCH VAR TS PATH
 do
  if [ "$VAR" = 'default' -a "$ARCH" = "$R_ARCH" ]
  then
   TL+=("$DISTRO / $RELEASE")
   PL+=("$PATH")
   DL+=("$DISTRO")
   RL+=("$RELEASE")
  fi
 done

 show_list "${TL[@]}"
 N=$(read_list_elt "${#PL[@]}")

 if [ "$N" -lt 0 ] ; then
  exit 0
 fi

 local D="${DL[$N]}"
 local R="${RL[$N]}"
 local P="${PL[$N]}"
 echo "${D@Q} ${R@Q} ${P@Q}"
}

ARGS=($("$TERMSH" cat \
https://images.linuxcontainers.org/meta/1.0/index-user \
| chooser))

if [ -z "$ARGS" ] ; then exit 0 ; fi

export ROOTFS_URL="https://images.linuxcontainers.org/${ARGS[2]}/rootfs.tar.xz"

S='install-linuxcontainers.sh'
"$TERMSH" copy -f -fu \
"https://raw.githubusercontent.com/green-green-avk/AnotherTerm-scripts/master/$S" \
-tp . && chmod 755 "$S" && sh "./$S" -a "${ARGS[0]}" "${ARGS[1]}"
