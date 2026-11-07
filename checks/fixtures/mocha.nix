# Catppuccin Mocha as a Base16 scheme plus overrides: a test fixture for the importer and the
# override mechanism, not a flavor. The background is Catppuccin's `crust` and base04 is
# `subtext1`; the overrides are Catppuccin's own colors for roles the slots cannot carry.
{ lib, mkColorscheme }:
let
  slots = {
    base00 = "#11111b"; # crust
    base01 = "#313244"; # surface0
    base02 = "#45475a"; # surface1
    base03 = "#6c7086"; # overlay0
    base04 = "#bac2de"; # subtext1
    base05 = "#cdd6f4"; # text
    base06 = "#f5e0dc"; # rosewater
    base07 = "#b4befe"; # lavender
    base08 = "#f38ba8"; # red
    base09 = "#fab387"; # peach
    base0A = "#f9e2af"; # yellow
    base0B = "#a6e3a1"; # green
    base0C = "#94e2d5"; # teal
    base0D = "#89b4fa"; # blue
    base0E = "#cba6f7"; # mauve
    base0F = "#f2cdcd"; # flamingo
  };

  overrides = {
    surface_subtle = "#181825"; # mantle
    border = "#585b70"; # surface2
    special = "#f5c2e7"; # pink
    hint = "#94e2d5"; # teal
    builtin = "#f38ba8"; # red
    info = "#89dceb"; # sky
    operator = "#89dceb"; # sky
    parameter = "#eba0ac"; # maroon
    property = "#b4befe"; # lavender
    tag = "#f2cdcd"; # flamingo
    cursor = "#f5e0dc"; # rosewater
  };

  meta = {
    slug = "mocha-fixture";
    name = "Mocha (fixture)";
    author = "Catppuccin";
    variant = "dark";
  };

  first = mkColorscheme { inherit slots overrides meta; };
  c = first.roles;
in
mkColorscheme {
  inherit slots overrides meta;

  ansi = [
    c.selection c.error c.success c.warning c.func c.special c.hint c.fg_muted
    c.border c.error c.success c.warning c.func c.special c.hint c.fg
  ];
}
