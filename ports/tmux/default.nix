# tmux: status line, window labels (activity recolors the text, a bell fills the label), pane
# borders and messages.
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
    set -g status-style "bg=${r.surface},fg=${r.fg_muted}"
    set -g window-status-current-style "bg=${r.selection},fg=${r.fg}"
    set -g window-status-activity-style "fg=${r.warning}"
    set -g window-status-bell-style "bg=${r.warning},fg=${r.bg}"
    set -g pane-border-style "fg=${r.border}"
    set -g pane-active-border-style "fg=${r.accent}"
    set -g message-style "bg=${r.surface},fg=${r.fg}"
    set -g mode-style "bg=${r.selection},fg=${r.fg}"
  '';
  install = ''
    # tmux

    Add to `~/.config/tmux/tmux.conf`:

    ```
    source-file /usr/share/malachite/${slug}/tmux/malachite-${slug}.conf
    ```

    A package installs the file there; otherwise use the path of `malachite-${slug}.conf`. Reload with
    `tmux source-file ~/.config/tmux/tmux.conf`. For the bell label to show, set `monitor-bell on`.
  '';
}
