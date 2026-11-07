# mako: a surface card on whatever is behind it, a quiet selection border, and the error color only
# for urgent notifications. Font, border size and radius are the consumer's style. `settings` is the
# same content as `text`, for modules that take structured settings.
{
  lib,
  colorscheme,
  ...
}:
let
  r = colorscheme.roles;
  slug = colorscheme.slug;

  settings = {
    background-color = r.surface;
    text-color = r.fg;
    border-color = r.selection;
    progress-color = "over ${r.selection}";
    "urgency=high".border-color = r.error;
  };
in
{
  file = "malachite-${slug}.conf";
  inherit settings;
  text = lib.generators.toINIWithGlobalSection { } {
    globalSection = lib.filterAttrs (_: lib.isString) settings;
    sections = lib.filterAttrs (_: lib.isAttrs) settings;
  };
  install = ''
    # mako

    mako has no include directive: copy these lines into `~/.config/mako/config`, with the
    `[urgency=high]` section after your other sections, then run `makoctl reload`.
  '';
}
