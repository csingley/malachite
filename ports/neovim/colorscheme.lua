-- Malachite for Neovim: tinted-nvim (a Base16 theme plugin) given a scheme built from the roles,
-- plus the overrides below. The plugin colors every group from the 16 slots; the overrides keep what
-- the slots cannot say (warnings amber, errors carmine, italic control flow, bold return, the comment
-- tags). Overrides name roles, never hex values. Requires the tinted-nvim plugin.
local P = __ROLES__

local function blend(fg, bg, alpha)
  local function ch(i)
    local a = tonumber(fg:sub(i, i + 1), 16)
    local b = tonumber(bg:sub(i, i + 1), 16)
    return math.floor(math.min(math.max(0, alpha * a + (1 - alpha) * b), 255) + 0.5)
  end
  return ("#%02x%02x%02x"):format(ch(2), ch(4), ch(6))
end

-- Raised steps from the background toward surface, for floats, menus and the statusline.
P.panel = blend(P.surface, P.bg, 0.30)
P.panel_subtle = blend(P.surface, P.bg, 0.15)

if not pcall(require, "tinted-nvim") then
  vim.notify("malachite: the tinted-nvim plugin is required", vim.log.levels.WARN)
  return
end

-- The syntax slots. Base16 gives each hue one slot and a syntax plugin reads them by position
-- (base09 numbers, base0A types, base0B strings, base0D functions, base0E keywords). The slots
-- are therefore filled with the syntax roles. They are not the signal colors: the plugin would
-- paint numbers amber and variables carmine, so errors and warnings are set below instead.
local scheme = {
  variant = "dark",
  base00 = P.bg,
  base01 = P.surface,
  base02 = P.selection,
  base03 = P.fg_faint,
  base04 = P.fg_muted,
  base05 = P.fg,
  base06 = P.fg,
  base07 = P.fg,
  base08 = P.property, -- variables and identifiers (Base16 also uses it for errors: see below)
  base09 = P.number,
  base0A = P.type,
  base0B = P.string,
  base0C = P.special,
  base0D = P.func,
  base0E = P.keyword,
  base0F = P.fg_subtle,
}

-- Keywords are bold; control flow is also italic (set in the table below).
local bold_keywords = {
  "Keyword", "@keyword", "@keyword.function", "@keyword.import", "@keyword.operator", "@keyword.storage",
  "@keyword.modifier", "@keyword.type", "@keyword.coroutine", "@keyword.debug", "@keyword.export",
  "@keyword.conditional", "@keyword.repeat", "@keyword.exception", "@keyword.return",
}

local function overrides()
  local kw = P.keyword
  local t
  t = {
    -- Syntax: what the slots cannot say
    ["@variable.parameter"] = { fg = P.parameter },
    ["@property"] = { fg = P.property },
    ["Operator"] = { fg = P.operator },
    ["@operator"] = { fg = P.operator },
    ["@keyword.conditional"] = { fg = kw, italic = true },
    ["@keyword.repeat"] = { fg = kw, italic = true },
    ["@keyword.exception"] = { fg = kw, italic = true },
    ["@keyword.return"] = { fg = kw, bold = true },
    ["@keyword.return.bash"] = { fg = kw, bold = true },
    ["@string.documentation"] = { fg = P.comment, italic = true },
    ["@comment.documentation"] = { fg = P.comment },
    ["@keyword.import"] = { fg = kw },
    ["@keyword.import.c"] = { fg = P.type },
    ["@keyword.import.cpp"] = { fg = P.type },
    ["@keyword.directive"] = { fg = P.special },
    ["@keyword.directive.define"] = { fg = P.special },
    ["@function.builtin"] = { fg = P.number },
    ["@function.builtin.bash"] = { fg = P.builtin },
    ["@lsp.typemod.function.builtin"] = { fg = P.number },
    ["@lsp.typemod.function.defaultLibrary"] = { fg = P.number },
    ["@function.macro"] = { fg = P.special },
    ["@constant.macro"] = { fg = kw },
    ["@constructor"] = { fg = P.type },
    ["@attribute"] = { fg = P.number },

    ["@variable"] = { fg = P.fg_muted },
    ["@variable.builtin"] = { fg = P.builtin },
    ["@variable.member"] = { fg = P.property },
    ["@module"] = { fg = P.type, italic = true },
    ["@type.builtin"] = { fg = kw },
    ["@punctuation.bracket"] = { fg = P.fg_subtle },
    ["@tag"] = { fg = P.func },
    ["@string.regexp"] = { fg = P.special },
    ["@markup.link"] = { fg = P.property },
    ["@markup.strong"] = { fg = P.builtin, bold = true },

    -- Comment tags are colored bold text, not filled blocks
    ["@comment.error"] = { fg = P.error, bold = true },
    ["@comment.warning"] = { fg = P.warning, bold = true },
    ["@comment.note"] = { fg = P.hint, bold = true },
    ["@comment.todo"] = { fg = P.number, bold = true },
    ["Todo"] = { fg = P.number, bold = true },

    -- Errors and warnings: the signal colors (Base16 would use its slots 08 and 09)
    ["Error"] = { fg = P.error },
    ["ErrorMsg"] = { fg = P.error },
    ["WarningMsg"] = { fg = P.warning },
    ["DiagnosticError"] = { fg = P.error },
    ["DiagnosticSignError"] = { fg = P.error },
    ["DiagnosticVirtualTextError"] = { fg = P.error },
    ["DiagnosticUnderlineError"] = { underline = true, sp = P.error },
    ["DiagnosticWarn"] = { fg = P.warning },
    ["DiagnosticSignWarn"] = { fg = P.warning },
    ["DiagnosticVirtualTextWarn"] = { fg = P.warning },
    ["DiagnosticUnderlineWarn"] = { underline = true, sp = P.warning },
    ["DiagnosticUnderlineInfo"] = { underline = true, sp = P.info },
    ["DiagnosticUnderlineHint"] = { underline = true, sp = P.hint },
    ["DiagnosticInfo"] = { fg = P.info },
    ["DiagnosticHint"] = { fg = P.hint },

    -- The editor chrome. panel and panel_subtle are raised steps from the background toward surface
    -- (palette.lua), so floats, menus and the statusline stand apart from the editor in any palette.
    ["LineNr"] = { fg = blend(P.keyword, P.bg, 0.55) }, -- the structure color, quieter
    ["CursorLineNr"] = { fg = P.keyword, bold = true },
    ["CursorLine"] = { bg = blend(P.bg, P.surface, 0.36) },
    ["SnacksIndent"] = { fg = blend(P.keyword, P.bg, 0.7) }, -- the indent guide
    ["SnacksIndentScope"] = { link = "Special" },
    ["WinSeparator"] = { fg = P.selection },
    ["NormalFloat"] = { fg = P.fg, bg = P.panel },
    ["FloatBorder"] = { fg = P.accent, bg = P.panel },
    ["FloatTitle"] = { fg = P.fg_muted, bg = P.panel },
    ["Pmenu"] = { fg = P.fg_subtle, bg = P.panel },
    ["PmenuSel"] = { bg = P.surface, bold = true },
    ["PmenuSbar"] = { bg = P.surface },
    ["PmenuThumb"] = { bg = P.fg_faint },
    ["PmenuMatch"] = { fg = P.fg, bold = true },
    ["StatusLine"] = { fg = P.fg, bg = P.panel },
    ["StatusLineNC"] = { fg = P.selection, bg = P.panel },
    ["Search"] = { fg = P.fg, bg = blend(P.info, P.bg, 0.3) },
    ["CurSearch"] = { fg = P.bg, bg = P.builtin },
    ["IncSearch"] = { fg = P.bg, bg = blend(P.info, P.bg, 0.9) },
    ["MatchParen"] = { fg = P.number, bg = blend(P.selection, P.bg, 0.7), bold = true },

    -- The visual selection: surface, not bold (selection is a loud slab in saturated greens)
    ["Visual"] = { bg = P.surface },
    ["VisualNOS"] = { bg = P.surface },
  }
  for _, name in ipairs(bold_keywords) do
    t[name] = vim.tbl_extend("force", { fg = kw }, t[name] or {}, { bold = true })
  end
  return t
end

require("tinted-nvim").setup({
  apply_scheme_on_startup = false,
  ui = { transparent = __TRANSPARENT__ },
  schemes = { ["base16-malachite-__SLUG__"] = scheme },
  highlights = { overrides = overrides },
})
require("tinted-nvim").load("base16-malachite-__SLUG__")
vim.g.colors_name = "malachite-__SLUG__"

-- :terminal colors: the palette's ANSI list, the same colors foot uses
for i, color in ipairs(P.ansi or {}) do
  vim.g["terminal_color_" .. (i - 1)] = color
end
