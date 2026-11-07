# foot: the `[colors-dark]` section. `alpha` is the background opacity (unset: foot's default).
{
  lib,
  colorscheme,
  alpha ? null,
  ...
}:
let
  r = colorscheme.roles;
  hex = lib.removePrefix "#";
  slug = colorscheme.slug;
  ansi = lib.imap0 (
    i: c: "${if i < 8 then "regular${toString i}" else "bright${toString (i - 8)}"}=${hex c}"
  ) colorscheme.ansi;
in
{
  file = "malachite-${slug}.ini";
  native = "foot/themes/malachite-${slug}";
  text = ''
    [colors-dark]
    ${lib.optionalString (alpha != null) "alpha=${toString alpha}\n"}background=${hex r.bg}
    foreground=${hex r.fg}
    cursor=${hex r.bg} ${hex r.cursor}
    selection-foreground=${hex r.fg}
    selection-background=${hex r.selection}
    ${lib.concatStringsSep "\n" ansi}
  '';
  install = ''
    # foot

    Add to `~/.config/foot/foot.ini` (the path is absolute, or starts with `~/`):

    ```ini
    include=/usr/share/foot/themes/malachite-${slug}
    ```

    From a package the file is at `/usr/share/foot/themes/malachite-${slug}`; otherwise use the path
    of `malachite-${slug}.ini`. New foot windows pick it up. Written for foot 1.28 (`[colors-dark]`).
  '';
}
