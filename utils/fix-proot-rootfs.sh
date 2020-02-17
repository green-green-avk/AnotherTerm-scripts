#!/system/bin/sh

set -e

OP='.l2s.'
P='.proot'

if [ -n "$2" ] ; then
shift
prepend() {
echo "$(dirname "$1")/$P$(basename "$1")"
}
relink() {
[ -L "$1" ] || return 0
local L="$(readlink "$1")"
[[ $(basename "$L") = $OP* ]] && { echo "Relinking: $1 -> $L" ; ln -snf "$(prepend "$L")" "$1" ; }
}
relink "$1"
[[ $(basename "$1") = $OP* ]] && { echo " Renaming: $1" ; mv -f "$1" "$(prepend "$1")" ; }
exit 0
fi

find "${1:-.}" \( -name "$OP"\* -or -type l \) -exec "$0" - '{}' \;
