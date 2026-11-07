# Jade: Emerald's restrained flavor. Its greens are mixed toward gray, so it reads as olive. Nearly
# every color is a green; amber (warning) and carmine (error) are the exceptions.
{ lib, mkColorscheme, mix }:
let
  slots = {
    base00 = "#050901"; # bg
    base01 = "#20360c"; # surface
    base02 = "#314e16"; # selection
    base03 = "#628042"; # fg_faint
    base04 = "#d7dcd1"; # fg_muted
    base05 = "#eef0ea"; # fg
    base06 = "#eef0ea";
    base07 = "#eef0ea";
    base08 = "#ed1c31"; # error: carmine
    base09 = "#abee63"; # number: peridot
    base0A = "#ffbc3d"; # warning: amber
    base0B = "#76b900"; # success: lime
    base0C = "#b0e48b"; # special
    base0D = "#76b900"; # accent
    base0E = "#62d043"; # keyword
    base0F = "#a0b08d";
  };

  # The syntax tones that need their own greens, and roles derived from them.
  overrides = c: {
    string = "#4db342";
    func = "#a3f5c1"; # pale mint
    type = "#5ad899"; # cool emerald

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
    slug = "jade";
    name = "Jade";
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
