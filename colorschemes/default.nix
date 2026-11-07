# The flavors Malachite ships.
{ lib, mkColorscheme, mix }:
{
  emerald = import ./emerald.nix { inherit lib mkColorscheme mix; };
  jade = import ./jade.nix { inherit lib mkColorscheme mix; };
}
