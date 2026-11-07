# btop: a theme file. Load gauges (cpu, temp, used) run green to amber to scarlet; the rest are greens.
# Everything is muted: btop is dense, and bright colors on every row are tiring.
{
  lib,
  colorscheme,
  color,
  ...
}:
let
  r = colorscheme.roles;
  slug = colorscheme.slug;

  gradient = name: start: mid: end: {
    "${name}_start" = start;
    "${name}_mid" = mid;
    "${name}_end" = end;
  };

  # btop is dense, so everything is toned down toward the background: the text, the box lines and
  # the gauges. `dim c` keeps `1 - t` of the color.
  dim = c: t: color.mix c r.bg t;

  colors =
    {
      main_bg = r.bg;
      main_fg = r.fg_muted;
      title = r.fg_muted;
      hi_fg = dim r.accent 0.3;
      selected_bg = r.selection;
      selected_fg = r.fg;
      inactive_fg = r.fg_faint;
      graph_text = r.fg_faint;
      meter_bg = r.surface;
      proc_misc = dim r.special 0.45;
      cpu_box = dim r.border 0.45;
      mem_box = dim r.border 0.45;
      net_box = dim r.border 0.45;
      proc_box = dim r.border 0.45;
      div_line = dim r.border 0.6;
    }
    // gradient "cpu" (dim r.success 0.3) (dim r.warning 0.3) (dim r.error 0.3)
    // gradient "used" (dim r.success 0.3) (dim r.warning 0.3) (dim r.error 0.3)
    // gradient "process" (dim r.success 0.4) (dim r.warning 0.4) (dim r.error 0.4)
    // gradient "temp" (dim r.success 0.3) (dim (color.mix r.success r.warning 0.3) 0.3) (dim r.error 0.3)
    // gradient "free" (dim r.success 0.7) (dim r.success 0.5) (dim r.success 0.3)
    // gradient "available" (dim r.success 0.7) (dim r.success 0.5) (dim r.success 0.3)
    // gradient "download" (dim r.success 0.7) (dim r.success 0.5) (dim r.success 0.3)
    // gradient "cached" (dim r.type 0.65) (dim r.type 0.45) (dim r.func 0.3)
    // gradient "upload" (dim r.accent 0.65) (dim r.accent 0.45) (dim r.number 0.3);
in
{
  file = "malachite-${slug}.theme";
  native = "btop/themes/malachite-${slug}.theme";
  text = lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: ''theme[${k}]="${v}"'') colors) + "\n";
  install = ''
    # btop

    Copy `malachite-${slug}.theme` to `~/.config/btop/themes/` (a package installs it to
    `/usr/share/btop/themes/`). In btop press Esc, open Options and choose the color theme
    `malachite-${slug}`, or set it in `~/.config/btop/btop.conf`:

    ```
    color_theme = "malachite-${slug}"
    ```

    To let the terminal background show through, also set `theme_background = False`.
  '';
}
