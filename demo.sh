#!/bin/bash

tmp="${TMPDIR:-/tmp}/$$.tmp"
mkdir -m 700 "$tmp"
trap 'rm -Rf "$tmp"' EXIT
touch "$tmp/.bash_profile" "$tmp/.bashrc"
ln -s "$PWD" "$tmp/angel-PS1"

out="$tmp/out"

unset PS1
HOME="$tmp"
cd ~/angel-PS1 ; script -q -e -c 'bash -l' "$out" <<'EOF'
echo ; stty echo
echo $PS1
# == Load angel-PS1 with default prompt =====
eval $(./angel-PS1)
angel off
angel on
angel quit
# == Load angel-PS1 with Powerline-basic.PS1
eval $(./angel-PS1 -c examples/Powerline-basic.PS1)
angel quit
set | grep ^APS1
# == Load angel-PS1 with 2lines.PS1
eval $(./angel-PS1 -c examples/2lines.PS1)
exit
EOF

sleep 3
echo -------------------------------------------------------------------------------
cat "$out"
echo -------------------------------------------------------------------------------
