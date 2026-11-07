# sway: window colors. The focused window has a surface title bar and brighter text; unfocused
# windows have a bg title bar and a surface border; an urgent window is the error color. Each
# line is `border background text indicator child_border`.
{
  colorscheme,
  ...
}:
let
  r = colorscheme.roles;
  slug = colorscheme.slug;
in
{
  file = "malachite-${slug}.conf";
  text = ''
    client.focused ${r.border} ${r.surface} ${r.fg} ${r.fg_muted} ${r.border}
    client.focused_inactive ${r.selection} ${r.surface_subtle} ${r.fg_muted} ${r.selection} ${r.selection}
    client.unfocused ${r.surface} ${r.bg} ${r.fg_subtle} ${r.surface} ${r.surface}
    client.urgent ${r.error} ${r.error} ${r.bg} ${r.error} ${r.error}
    client.placeholder ${r.selection} ${r.bg} ${r.fg_muted} ${r.selection} ${r.selection}
    client.background ${r.bg}
  '';
  install = ''
    # sway

    Add to `~/.config/sway/config` and reload with `swaymsg reload`:

    ```
    include /usr/share/malachite/${slug}/sway/malachite-${slug}.conf
    ```

    A package installs the file there; otherwise use the path of `malachite-${slug}.conf`.
  '';
}
