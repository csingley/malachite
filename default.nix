# The non-flake entry point: everything the flake exports, as plain Nix.
#
#   nix-instantiate --eval --strict -E '(import ./. { }).colorschemes.emerald.roles'
{
  lib ? import <nixpkgs/lib>,
}:
let
  color = import ./lib/color.nix { inherit lib; };
  malachiteLib = import ./lib { inherit lib; };

  # Each port as a function of a colorscheme: `ports.fzf colorscheme` is { file, text, install, ... }.
  ports = lib.mapAttrs (
    _: path: colorscheme: import path { inherit lib colorscheme color; }
  ) (import ./ports);
in
{
  lib = malachiteLib // {
    inherit ports;
  };
  colorschemes = import ./colorschemes {
    inherit lib;
    inherit (malachiteLib) mkColorscheme;
    inherit (color) mix;
  };
}
