# Emerald: saturated greens anchored to lime, peridot and forest, with
# amber for warning and scarlet for error. Jade is the restrained flavor.
{ lib, mkColorscheme, mix }:
let
  slots = {
    base00 = "#061203"; # bg
    base01 = "#103a04"; # surface
    base02 = "#1e570a"; # selection
    base03 = "#50a824"; # fg_faint
    base04 = "#cde8ba"; # fg_muted
    base05 = "#f2f8ed"; # fg
    base06 = "#f2f8ed";
    base07 = "#f2f8ed";
    base08 = "#ed311c"; # error: scarlet
    base09 = "#c4f23a"; # number: peridot
    base0A = "#ffc21a"; # warning: amber
    base0B = "#27ce32"; # success: emerald
    base0C = "#9cf06a"; # special
    base0D = "#76b900"; # accent: lime
    base0E = "#4fe03d"; # keyword
    base0F = "#92ca72";
  };

  # The syntax tones that need their own greens, and roles derived from them.
  overrides = c: {
    string = "#2bb642"; # emerald
    func = "#9af5c5"; # mint
    type = "#3fe0a0"; # jade

    builtin = mix c.func c.string 0.6;
    tag = mix c.keyword c.fg 0.75;
    cursor = mix c.number c.fg 0.85;
    info = mix c.func c.string 0.2;
    operator = mix c.fg_faint c.func 0.4;
    hint = mix c.string c.type 0.7;
    parameter = mix c.fg c.success 0.4;
    property = mix c.bg c.func 0.7;
  };

  meta = {
    slug = "emerald";
    name = "Emerald";
    author = "Chris Singley";
    variant = "dark";
  };

  first = mkColorscheme { inherit slots overrides meta; };
  c = first.roles;
  bright = x: mix x c.fg 0.3; # 30% toward fg
  cyan = mix c.bg c.hint 0.8;
in
mkColorscheme {
  inherit slots overrides meta;

  ansi = [
    c.surface c.error c.success c.warning c.type c.special cyan c.fg_muted
    c.fg_subtle (bright c.error) (bright c.success) (bright c.warning) (bright c.type) (bright c.special) (bright cyan) c.fg
  ];
}
