# waybar: the roles as GTK `@define-color` lines for the bar's stylesheet.
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
    # waybar

    Put `malachite-${slug}.css` next to `~/.config/waybar/style.css` and add this at its top:

    ```css
    @import "malachite-${slug}.css";
    ```

    Then use the colors as `@bg`, `@surface`, `@warning` and so on. Reload with
    `killall -SIGUSR2 waybar`.
  '';
}
