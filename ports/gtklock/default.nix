# gtklock: the roles as GTK `@define-color` lines for the lock screen's stylesheet.
{
  colorscheme,
  ...
}:
let
  slug = colorscheme.slug;
in
{
  file = "malachite-${slug}.css";
  text = import ../css.nix colorscheme;
  install = ''
    # gtklock

    Put `malachite-${slug}.css` next to your stylesheet and add this at its top:

    ```css
    @import "malachite-${slug}.css";
    ```

    Then use the colors as `@bg`, `@fg`, `@accent` and so on. gtklock reads the stylesheet named by
    `style=` in `~/.config/gtklock/config.ini`.
  '';
}
