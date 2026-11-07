# Base16 (the tinted-theming YAML format) in and out, without a YAML parser: scheme files are
# flat, so each line is matched on its own.
{ lib }:
let
  color = import ./color.nix { inherit lib; };
  slotLine = builtins.match ''[[:space:]]*(base0[0-9A-Fa-f])[[:space:]]*:[[:space:]]*"?#?([0-9A-Fa-f]{6})"?.*'';
  fieldLine = key: builtins.match ''${key}:[[:space:]]*"?([^"]*)"?[[:space:]]*'';
  lines = text: builtins.filter builtins.isString (builtins.split "\n" text);

  # The 16 Base16 slots from a colorscheme's roles (the export). base06 and base07 are not read
  # by Malachite, so they are written as `fg`; base09 is `number`; base0F is `fg_subtle`.
  toSlots = r: {
    base00 = r.bg;
    base01 = r.surface;
    base02 = r.selection;
    base03 = r.fg_faint;
    base04 = r.fg_muted;
    base05 = r.fg;
    base06 = r.fg;
    base07 = r.fg;
    base08 = r.error;
    base09 = r.number;
    base0A = r.warning;
    base0B = r.success;
    base0C = r.special;
    base0D = r.accent;
    base0E = r.keyword;
    base0F = r.fg_subtle;
  };
in
{
  inherit toSlots;

  # YAML text -> { name, author, variant, slots = { base00 = "#rrggbb"; ... base0f } }
  parse =
    text:
    let
      ls = lines text;
      slots = lib.listToAttrs (
        lib.concatMap (
          l:
          let
            m = slotLine l;
          in
          lib.optional (m != null) (
            lib.nameValuePair (lib.toLower (builtins.elemAt m 0)) (color.norm (builtins.elemAt m 1))
          )
        ) ls
      );
      field =
        key:
        let
          hits = lib.concatMap (l: lib.optional (fieldLine key l != null) (builtins.head (fieldLine key l))) ls;
        in
        if hits == [ ] then null else builtins.head hits;
    in
    {
      name = field "name";
      author = field "author";
      variant = field "variant";
      inherit slots;
    };

  # A tinted-theming scheme file for a colorscheme
  toYaml =
    cs:
    let
      slots = toSlots cs.roles;
    in
    ''
      system: "base16"
      name: "${cs.name}"
      author: "${cs.author}"
      variant: "${cs.variant}"
      palette:
    ''
    + lib.concatMapStrings (k: "  ${k}: \"${slots.${k}}\"\n") (lib.attrNames slots);
}
