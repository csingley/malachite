# swaynag: the `warning` banner is a surface with a red edge (it confirms something destructive);
# `error` is the error color. Colors are RRGGBB. There is no `button-border=<color>`: swaynag parses
# it as a prefix of `--button-border-size` and the hex digits become a huge thickness.
{
  lib,
  colorscheme,
  ...
}:
let
  r = lib.mapAttrs (_: lib.removePrefix "#") colorscheme.roles;
  slug = colorscheme.slug;
in
{
  file = "malachite-${slug}.conf";
  text = ''
    [warning]
    background=${r.surface}
    text=${r.fg}
    border=${r.selection}
    border-bottom=${r.error}
    button-background=${r.selection}
    button-text=${r.fg}

    [error]
    background=${r.error}
    text=${r.bg}
    border=${r.error}
    border-bottom=${r.bg}
    button-background=${r.bg}
    button-text=${r.fg}
  '';
  install = ''
    # swaynag

    swaynag has no include directive: copy these sections into `~/.config/swaynag/config`. Pick a
    banner with `swaynag -t warning` or `-t error`.
  '';
}
