#!/bin/bash

tmp="${TMPDIR:-/tmp}/$$.tmp"
mkdir -m 700 "$tmp"
trap 'rm -Rf "$tmp"' EXIT
touch "$tmp/.bash_profile"

out="$tmp/out"

unset PS1
HOME="$tmp"
script -q -e -c bash <<'EOF' > "$out"
echo -e '# == Loading with default prompt ====='
echo 'eval $(./angel-PS1)' ; eval $(./angel-PS1)
echo -e '# == Loading with 2lines.PS1 '
echo 'eval $(./angel-PS1 -c examples/2lines.PS1)' ; eval $(./angel-PS1 -c examples/2lines.PS1)
echo -e '# == Loading with Powerline-basic.PS1'
echo 'eval $(./angel-PS1 -c examples/Powerline-basic.PS1)' ; eval $(./angel-PS1 -c examples/Powerline-basic.PS1)
exit
EOF

sleep 3
echo -------------------------------------------------------------------------------
cat "$out"
echo -------------------------------------------------------------------------------
