# The ports: each is a function `{ lib, colorscheme, color, ... } -> { file, text, install, native? }`.
#   file     the artifact's name, under share/malachite/<flavor>/<port>/
#   text     its contents
#   install  INSTALL.md: where the file goes and how to load it
#   native   an extra install path under share/, where the app searches for themes by name
{
  btop = ./btop;
  claude-code = ./claude-code;
  foot = ./foot;
  fzf = ./fzf;
  gtklock = ./gtklock;
  htop = ./htop;
  lualine = ./lualine;
  mako = ./mako;
  neovim = ./neovim;
  sway = ./sway;
  swaynag = ./swaynag;
  terminal = ./terminal;
  tmux = ./tmux;
  waybar = ./waybar;
}
