# The packages: the core (colorschemes as JSON and Base16) and one per port, each for every flavor,
# laid out under share/ (README.md "Stability" lists the stable paths).
{
  lib,
  runCommand,
  writeText,
  symlinkJoin,
  malachite,
  src,
  nfpm ? null,
  colorschemes ? malachite.colorschemes,
}:
let
  color = import ../lib/color.nix { inherit lib; };
  ports = import ../ports;
  flavors = lib.attrValues colorschemes;

  meta = {
    description = "Malachite colorscheme files for terminals, editors and desktops";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };

  render = port: colorscheme: import ports.${port} { inherit lib colorscheme color; };

  portPackage =
    port:
    runCommand "malachite-colorscheme-${port}" { inherit meta; } (
      "mkdir -p $out/share\n"
      + lib.concatMapStrings (
        colorscheme:
        let
          p = render port colorscheme;
          dir = "$out/share/malachite/${colorscheme.slug}/${port}";
          artifact = writeText p.file p.text;
        in
        ''
          mkdir -p ${dir}
          cp ${artifact} ${dir}/${p.file}
          cp ${writeText "INSTALL.md" p.install} ${dir}/INSTALL.md
        ''
        + lib.optionalString (p ? native) ''
          mkdir -p $out/share/${builtins.dirOf p.native}
          cp ${artifact} $out/share/${p.native}
        ''
      ) flavors
    );

  core =
    runCommand "malachite-colorscheme" { inherit meta; } (
      "mkdir -p $out/share/doc/malachite-colorscheme\n"
      + "cp ${src}/README.md ${src}/LICENSE $out/share/doc/malachite-colorscheme/\n"
      + lib.concatMapStrings (colorscheme: ''
        mkdir -p $out/share/malachite/${colorscheme.slug}
        cp ${writeText "colorscheme.json" (builtins.toJSON colorscheme)} $out/share/malachite/${colorscheme.slug}/colorscheme.json
        cp ${writeText "base16.yaml" (malachite.lib.toBase16Yaml colorscheme)} $out/share/malachite/${colorscheme.slug}/base16.yaml
      '') flavors
    );

  byPort = lib.mapAttrs (port: _: portPackage port) ports;
  version = lib.fileContents ../VERSION;

  all = symlinkJoin {
    name = "malachite-colorscheme-all";
    inherit meta;
    paths = [ core ] ++ lib.attrValues byPort;
  };

  # The release tarball: the whole `share/` tree under `usr/`, the same for every architecture. The
  # distro packages (.deb, PKGBUILD) install this tree and nothing else.
  release = runCommand "malachite-colorscheme-${version}-tarball" { inherit meta; } ''
    mkdir -p stage/usr $out
    cp -rL ${all}/share stage/usr/share
    chmod -R u+w stage
    tar --sort=name --mtime=@0 --owner=0 --group=0 --numeric-owner -C stage -cf - usr \
      | gzip -n > $out/malachite-colorscheme-${version}.tar.gz
  '';

  # The .deb, from the same tree.
  deb = runCommand "malachite-colorscheme-${version}-deb" { nativeBuildInputs = [ nfpm ]; } ''
    mkdir -p stage $out
    tar -xzf ${release}/malachite-colorscheme-${version}.tar.gz -C stage
    cd stage
    VERSION=${version} nfpm package -f ${../packaging/nfpm.yaml} -p deb -t $out
  '';
in
byPort
// {
  colorscheme = core;
  default = all;
  inherit release;
}
// lib.optionalAttrs (nfpm != null) { inherit deb; }
