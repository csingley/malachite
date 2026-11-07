# The roles and the 16 terminal colors as a Lua table constructor, for the ports that run as Lua.
{ lib, colorscheme }:
let
  entries = lib.mapAttrsToList (n: v: "  ${n} = \"${v}\",") colorscheme.roles;
  ansi = lib.concatMapStringsSep ", " (c: "\"${c}\"") colorscheme.ansi;
in
"{\n${lib.concatStringsSep "\n" entries}\n  ansi = { ${ansi} },\n}"
