# htop: escape sequences that remap four terminal colors for one window. htop's color schemes are
# compiled in, so it draws with the terminal's ANSI palette; on its Default scheme these four slots
# carry the look:
#   foreground  default text, including normal processes
#   regular2    "Green": threads, the header bar and the meters
#   regular0    "Black": the text on the header, selection and F-key bars
#   regular6    "Cyan": the selected row, the F-key strip, megabyte-sized numbers
{
  lib,
  colorscheme,
  color,
  ...
}:
let
  r = colorscheme.roles;
  slug = colorscheme.slug;
  esc = builtins.fromJSON ''"\u001b"'';
  osc = args: "${esc}]${args}${esc}\\";
in
{
  file = "malachite-${slug}.osc";
  text = lib.concatStrings [
    (osc "10;${r.string}")
    (osc "4;0;${r.bg}")
    (osc "4;2;${color.mix r.bg r.special 0.85}")
    (osc "4;6;${r.fg_faint}")
  ];
  install = ''
    # htop

    htop has no theme files: it draws with the terminal's colors. Keep htop on its Default color
    scheme (F2 Setup > Colors), print this file in the terminal, then run htop:

    ```sh
    cat /usr/share/malachite/${slug}/htop/malachite-${slug}.osc; htop
    ```

    The change lasts until that terminal closes. Works in any terminal that supports OSC 4 and 10
    (foot, kitty, alacritty, wezterm, xterm), including over ssh; tested on foot and xterm.
  '';
}
