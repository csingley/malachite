# Color arithmetic on "#rrggbb" strings: mixing and WCAG contrast.
{ lib }:
let
  table = import ./srgb-linear.nix;

  # "#RRGGBB", "rrggbb" or "#rrggbb" -> "#rrggbb"
  norm = h: lib.toLower (if builtins.substring 0 1 h == "#" then h else "#" + h);

  chan = h: i: lib.fromHexString (builtins.substring i 2 h);
  hex2 =
    n:
    let
      s = lib.toLower (lib.toHexString n);
    in
    if builtins.stringLength s < 2 then "0" + s else s;

  # The color `t` of the way from `a` to `b`, t from 0 to 1.
  mix =
    a: b: t:
    "#"
    + lib.concatMapStrings (
      i: hex2 (builtins.floor ((1 - t) * (chan a i) + t * (chan b i) + 0.5))
    ) [ 1 3 5 ];

  # WCAG relative luminance
  luminance =
    h:
    0.2126 * builtins.elemAt table (chan h 1)
    + 0.7152 * builtins.elemAt table (chan h 3)
    + 0.0722 * builtins.elemAt table (chan h 5);

  # WCAG contrast ratio of two colors, 1 to 21
  contrast =
    a: b:
    let
      la = luminance a;
      lb = luminance b;
    in
    (lib.max la lb + 0.05) / (lib.min la lb + 0.05);

  # `color` lightened toward `fg` in 5% steps until its contrast with `bg` reaches `target`.
  lightenTo =
    fg: color: bg: target:
    let
      candidate = i: if i == 0 then color else mix color fg (i * 0.05);
    in
    candidate (lib.findFirst (i: contrast (candidate i) bg >= target) 20 (lib.range 0 20));
in
{
  inherit
    norm
    mix
    luminance
    contrast
    lightenTo
    ;
}
