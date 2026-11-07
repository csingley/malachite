# neovim: a colorscheme for Neovim, built on the tinted-nvim plugin (README: what it needs).
{
  lib,
  colorscheme,
  transparent ? true,
  ...
}:
let
  slug = colorscheme.slug;
  luaTable = import ../lua-table.nix { inherit lib colorscheme; };
in
{
  file = "malachite-${slug}.lua";
  native = "nvim/site/colors/malachite-${slug}.lua";
  text =
    builtins.replaceStrings
      [ "__ROLES__" "__SLUG__" "__TRANSPARENT__" ]
      [ luaTable slug (lib.boolToString transparent) ]
      (builtins.readFile ./colorscheme.lua);
  install = ''
    # neovim

    Needs the [tinted-nvim](https://github.com/tinted-theming/tinted-nvim) plugin. Put
    `malachite-${slug}.lua` in `~/.config/nvim/colors/` (or any `colors/` directory on Neovim's
    `runtimepath`), then:

    ```vim
    :colorscheme malachite-${slug}
    ```

    From a package the file is at `/usr/share/nvim/site/colors/malachite-${slug}.lua`, which Neovim
    already searches. The editor background is transparent (the terminal paints it); pass
    `transparent = false` to the port to paint it. The 16 terminal colors for `:terminal` are set
    too. For the statusline, see the lualine port.
  '';
}
