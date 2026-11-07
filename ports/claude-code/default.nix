# Claude Code: a custom theme. Each token gets the role that matches its meaning.
#
# The base is `dark-ansi`, not `dark`: the markdown renderer takes inline-code color from the base
# theme's `permission` token and ignores overrides, and `dark-ansi` draws it with the terminal's
# ANSI colors. Every token that matters is overridden; the base decides the rest.
{
  colorscheme,
  color,
  ...
}:
let
  r = colorscheme.roles;
  inherit (color) mix;
  slug = colorscheme.slug;

  shimmer = c: mix r.fg c 0.35; # the lighter end of an animated gradient
  tint = c: t: mix r.bg c t;
in
{
  file = "malachite-${slug}.json";
  text = builtins.toJSON {
    name = colorscheme.name;
    base = "dark-ansi";
    overrides = {
      # text and accents
      claude = r.accent; # the spinner and the assistant label
      claudeShimmer = shimmer r.accent;
      clawd_body = r.accent; # the mascot; an unknown token is ignored
      clawd_background = r.bg;
      text = r.fg;
      inverseText = r.bg;
      inactive = r.fg_subtle; # hints, timestamps, disabled items
      inactiveShimmer = shimmer r.fg_subtle;
      subtle = r.border;
      suggestion = r.type; # autocomplete and picker selection
      permission = r.warning; # dialog borders
      permissionShimmer = shimmer r.warning;
      remember = r.hint; # memory and CLAUDE.md indicators

      # status
      success = r.success;
      error = r.error;
      warning = r.warning;
      warningShimmer = shimmer r.warning;
      merged = r.keyword;

      # the input box and mode indicators
      promptBorder = r.border;
      promptBorderShimmer = shimmer r.border;
      planMode = r.hint;
      autoAccept = r.string;
      bashBorder = r.warning; # a `!` shell command
      ide = r.type;
      fastMode = r.number;
      fastModeShimmer = shimmer r.number;
      effortUltra = r.special;

      # diffs: tinted backgrounds, stronger on the changed words
      diffAdded = tint r.success 0.22;
      diffRemoved = tint r.error 0.22;
      diffAddedDimmed = tint r.success 0.12;
      diffRemovedDimmed = tint r.error 0.12;
      diffAddedWord = tint r.success 0.42;
      diffRemovedWord = tint r.error 0.42;

      # backgrounds: the same surface steps as a bar's pills
      userMessageBackground = r.surface;
      userMessageBackgroundHover = r.selection;
      bashMessageBackgroundColor = tint r.warning 0.1;
      memoryBackgroundColor = tint r.hint 0.12;
      selectionBg = r.selection;
      composerSidebarBackground = r.surface_subtle;

      # usage meter and speaker labels
      rate_limit_fill = r.accent;
      rate_limit_empty = r.selection;
      briefLabelYou = r.type;
      briefLabelClaude = r.accent;

      # the eight colors that tell parallel subagents apart
      red_FOR_SUBAGENTS_ONLY = r.error;
      blue_FOR_SUBAGENTS_ONLY = r.func;
      green_FOR_SUBAGENTS_ONLY = r.success;
      yellow_FOR_SUBAGENTS_ONLY = r.warning;
      purple_FOR_SUBAGENTS_ONLY = r.keyword;
      orange_FOR_SUBAGENTS_ONLY = r.number;
      pink_FOR_SUBAGENTS_ONLY = r.special;
      cyan_FOR_SUBAGENTS_ONLY = r.hint;
    };
  };
  install = ''
    # Claude Code

    Copy `malachite-${slug}.json` to `~/.claude/themes/`. Choose it with `/theme`, or set it in
    `~/.claude/settings.json`:

    ```json
    { "theme": "custom:malachite-${slug}" }
    ```

    Restart Claude Code to pick up a changed file.
  '';
}
