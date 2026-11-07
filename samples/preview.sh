#!/usr/bin/env bash
# Open a theme sample in Neovim with the UI-state scenes loaded (see ui-states.lua).
#   preview.sh                 the Python sample
#   preview.sh sample.sh       the shell sample
#   preview.sh /path/to/file   any file (the scenes that look for markers just skip)
dir=$(cd "$(dirname "$0")" && pwd)
file=${1:-$dir/sample.py}
[ -e "$file" ] || file="$dir/$file"
exec nvim -c "luafile $dir/ui-states.lua" "$file"
