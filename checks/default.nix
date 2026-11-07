# Conformance checks (`nix flake check`). Every Base16 scheme in nixpkgs, each flavor and the Mocha
# fixture go through mkColorscheme; check.py reads the report and scans the sources for unknown
# role names. Failures stop the build; contrast problems only warn.
{
  lib,
  runCommand,
  python3,
  writeText,
  base16-schemes,
  malachite,
  src,
}:
let
  mlib = malachite.lib;
  color = import ../lib/color.nix { inherit lib; };

  dir = "${base16-schemes}/share/themes";
  files = builtins.filter (lib.hasSuffix ".yaml") (builtins.attrNames (builtins.readDir dir));

  isHex = v: builtins.match "#[0-9a-f]{6}" v != null;
  allHex = xs: builtins.all isHex xs;

  # the slots read for roles; they must survive scheme -> roles -> slots
  used = [ "00" "01" "02" "03" "05" "08" "09" "0A" "0B" "0C" "0D" "0E" ];

  contrastOf = r: {
    fg = color.contrast r.fg r.bg;
    fg_muted = color.contrast r.fg_muted r.bg;
    fg_subtle = color.contrast r.fg_subtle r.bg;
    error = color.contrast r.error r.bg;
    warning = color.contrast r.warning r.bg;
    success = color.contrast r.success r.bg;
    accent = color.contrast r.accent r.bg;
    keyword = color.contrast r.keyword r.bg;
  };

  oneScheme =
    f:
    let
      sch = mlib.parseBase16 (builtins.readFile (dir + "/${f}"));
      cs = mlib.mkColorscheme { slots = sch.slots; };
      raw = mlib.mkColorscheme {
        slots = sch.slots;
        legibility.minContrast = 0;
      };
      back = mlib.toSlots cs.roles;
    in
    {
      variant = sch.variant;
      nslots = builtins.length (builtins.attrNames sch.slots);
      roles = builtins.attrNames cs.roles;
      allHex = allHex (builtins.attrValues cs.roles) && allHex cs.ansi;
      ansiLength = builtins.length cs.ansi;
      roundTrip = builtins.all (n: lib.toLower back."base${n}" == sch.slots."base${lib.toLower n}") used;
      # a colorscheme is pure data: toJSON fails if a function slips in
      json = builtins.stringLength (builtins.toJSON cs) > 0;
      contrast = (contrastOf cs.roles) // {
        fg_muted_unadjusted = color.contrast raw.roles.fg_muted raw.roles.bg;
        fg_subtle_unadjusted = color.contrast raw.roles.fg_subtle raw.roles.bg;
      };
    };

  oneFlavor = cs: {
    format = cs.format;
    roles = builtins.attrNames cs.roles;
    allHex = allHex (builtins.attrValues cs.roles) && allHex cs.ansi && allHex (builtins.attrValues cs.slots);
    ansiLength = builtins.length cs.ansi;
    json = builtins.stringLength (builtins.toJSON cs) > 0;
    contrast = contrastOf cs.roles;
  };

  report = {
    canonicalRoles = builtins.attrNames malachite.colorschemes.emerald.roles;
    schemes = lib.listToAttrs (map (f: lib.nameValuePair (lib.removeSuffix ".yaml" f) (oneScheme f)) files);
    flavors = lib.mapAttrs (_: oneFlavor) malachite.colorschemes;
    fixtures.mocha = oneFlavor (
      import ./fixtures/mocha.nix {
        inherit lib;
        inherit (mlib) mkColorscheme;
      }
    );
  };
in
runCommand "malachite-contract"
  {
    nativeBuildInputs = [ python3 ];
    report = writeText "malachite-report.json" (builtins.toJSON report);
    inherit src;
  }
  ''
    python3 ${./check.py} "$report" "$src"
    touch $out
  ''
