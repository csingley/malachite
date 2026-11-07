# lualine: the statusline theme for lualine.nvim, with the same mode colors as the neovim port.
{
  lib,
  colorscheme,
  ...
}:
let
  slug = colorscheme.slug;
  luaTable = import ../lua-table.nix { inherit lib colorscheme; };
in
{
  file = "malachite-${slug}.lua";
  native = "nvim/site/lua/lualine/themes/malachite-${slug}.lua";
  text = builtins.replaceStrings [ "__ROLES__" ] [ luaTable ] (builtins.readFile ./theme.lua);
  install = ''
    # lualine

    Put `malachite-${slug}.lua` in `~/.config/nvim/lua/lualine/themes/` (or any `lua/lualine/themes/`
    directory on Neovim's `runtimepath`), then:

    ```lua
    require("lualine").setup({ options = { theme = "malachite-${slug}" } })
    ```

    From a package the file is at `/usr/share/nvim/site/lua/lualine/themes/malachite-${slug}.lua`,
    which Neovim already searches.
  '';
}
