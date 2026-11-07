# Malachite's library: colorscheme construction, Base16 import and export, conversions, color mixing.
{ lib }:
let
  color = import ./color.nix { inherit lib; };
  base16 = import ./base16.nix { inherit lib; };
  mkColorscheme = import ./mkColorscheme.nix { inherit lib; };
in
{
  inherit mkColorscheme;
  inherit (color) mix;
  ramp = import ./ramp.nix { inherit lib; inherit (color) mix; };

  # "#rrggbb" -> "rrggbb", for tools that reject the "#"
  hex = lib.removePrefix "#";
  # `@define-color` lines for GTK CSS, one per role
  css = roles: lib.concatMapStrings (n: "@define-color ${n} ${roles.${n}};\n") (lib.attrNames roles);

  fromBase16Yaml =
    text:
    let
      p = base16.parse text;
    in
    mkColorscheme {
      slots = p.slots;
      meta = {
        name = if p.name == null then "Colorscheme" else p.name;
        author = if p.author == null then "" else p.author;
        variant = if p.variant == null then "dark" else p.variant;
      };
    };
  toBase16Yaml = base16.toYaml;
  inherit (base16) toSlots;
  parseBase16 = base16.parse;
}
