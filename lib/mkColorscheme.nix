# A colorscheme from the 16 Base16 slots. Roles are read from the slots or derived, and any role can
# be overridden. The result is pure data (strings and lists) and serializes to JSON.
#
#   slots       { base00 = "#rrggbb"; ... base0F = ...; } (either case, "#" optional)
#   overrides   roles to set, as an attribute set or a function of the final roles, so a derived
#               role follows an override of the role it derives from
#   ansi        the 16 terminal colors (default: derived from the roles)
#   legibility  { minContrast = 4.5; }: contrast fg_muted and fg_subtle are lightened to reach
#               against bg (0 turns the adjustment off)
#   meta        { slug, name, author, variant }
{ lib }:
{
  slots,
  overrides ? { },
  ansi ? null,
  legibility ? { },
  meta ? { },
}:
let
  color = import ./color.nix { inherit lib; };
  inherit (color) mix lightenTo;
  minContrast = legibility.minContrast or 4.5;

  # Normalized: lower-case values with "#", keys base00 ... base0F.
  key = k: "base" + lib.toUpper (lib.removePrefix "base" k);
  s = lib.mapAttrs' (k: v: lib.nameValuePair (key k) (color.norm v)) slots;
  required = map (n: "base0" + n) (lib.stringToCharacters "0123456789ABCDEF");
  missing = builtins.filter (k: !(s ? ${k})) required;

  # `self` is the final role set, overrides included.
  rolesOf =
    self:
    {
      # neutrals
      bg = s.base00;
      surface = s.base01;
      selection = s.base02;
      fg_faint = s.base03;
      fg = s.base05;
      surface_subtle = mix self.bg self.surface 0.10;
      border = mix self.selection self.fg_faint 0.40;
      fg_muted = if minContrast > 0 then lightenTo self.fg s.base04 self.bg minContrast else s.base04;
      fg_subtle =
        let
          start = mix self.fg_faint self.fg_muted 0.50;
        in
        if minContrast > 0 then lightenTo self.fg start self.bg minContrast else start;
      cursor = self.fg;

      # signals
      error = s.base08;
      warning = s.base0A;
      success = s.base0B;
      info = self.accent;
      hint = self.special;

      # identity and syntax
      accent = s.base0D;
      keyword = s.base0E;
      string = self.success;
      func = self.accent;
      type = self.warning;
      number = s.base09;
      special = s.base0C;
      builtin = mix self.func self.keyword 0.5;
      comment = self.fg_subtle;
      operator = self.fg_muted;
      property = mix self.fg self.func 0.5;
      parameter = self.fg;
      tag = self.fg;
    }
    // (if builtins.isFunction overrides then overrides self else overrides);

  roles = lib.fix rolesOf;

  bright = x: mix x roles.fg 0.3;
  defaultAnsi = [
    roles.surface
    roles.error
    roles.success
    roles.warning
    roles.accent
    roles.keyword
    roles.special
    roles.fg_muted
    roles.fg_subtle
    (bright roles.error)
    (bright roles.success)
    (bright roles.warning)
    (bright roles.accent)
    (bright roles.keyword)
    (bright roles.special)
    roles.fg
  ];
in
assert lib.assertMsg (missing == [ ]) "mkColorscheme: the slots lack ${lib.concatStringsSep ", " missing}";
{
  format = 1;
  slug = meta.slug or "colorscheme";
  name = meta.name or "Colorscheme";
  author = meta.author or "";
  variant = meta.variant or "dark";
  slots = s;
  inherit roles;
  ansi = if ansi != null then ansi else defaultAnsi;
}
