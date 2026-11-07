# terminal: the colorscheme as escape sequences that set a running terminal's colors (OSC 10, 11, 12
# and 4). `cat` the file in the terminal; it works in any terminal that supports them (foot, kitty,
# alacritty, wezterm, xterm, VTE), including over ssh, and lasts until the terminal closes.
{
  lib,
  colorscheme,
  ...
}:
let
  r = colorscheme.roles;
  slug = colorscheme.slug;
  esc = builtins.fromJSON ''"\u001b"'';
  osc = args: "${esc}]${args}${esc}\\";
  palette = lib.imap0 (i: c: osc "4;${toString i};${c}") colorscheme.ansi;
in
{
  file = "malachite-${slug}.osc";
  text = lib.concatStrings (
    [
      (osc "10;${r.fg}")
      (osc "11;${r.bg}")
      (osc "12;${r.cursor}")
    ]
    ++ palette
  );
  install = ''
    # terminal

    `malachite-${slug}.osc` holds escape sequences, not a config: print it in a terminal and that
    terminal takes the colors until it closes.

    ```sh
    cat /usr/share/malachite/${slug}/terminal/malachite-${slug}.osc
    ```

    Works over ssh too (the sequences go to the terminal you are sitting at). To theme every new
    terminal, add the `cat` line to your shell's startup file, or use the terminal's own config
    where a port exists (foot has one). Supported by foot, kitty, alacritty, wezterm, xterm and
    VTE terminals; tested on foot and xterm.
  '';
}
