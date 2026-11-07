# fzf: the `--color` option.
{
  colorscheme,
  ...
}:
let
  r = colorscheme.roles;
  slug = colorscheme.slug;
in
{
  file = "malachite-${slug}.fzf";
  text = "--color=${
    builtins.concatStringsSep "," [
      "fg:${r.fg_muted}"
      "bg:-1"
      "hl:${r.keyword}"
      "fg+:${r.fg}"
      "bg+:${r.surface}"
      "hl+:${r.keyword}"
      "pointer:${r.keyword}"
      "prompt:${r.keyword}"
      "info:${r.fg_subtle}"
      "gutter:-1"
    ]
  }\n";
  install = ''
    # fzf

    Point fzf at the file (it replaces any options already set in `~/.fzfrc`-style files):

    ```sh
    export FZF_DEFAULT_OPTS_FILE=/usr/share/malachite/${slug}/fzf/malachite-${slug}.fzf
    ```

    A package installs the file there; otherwise use the path of `malachite-${slug}.fzf`.
  '';
}
