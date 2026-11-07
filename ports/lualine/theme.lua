-- The Malachite statusline theme for lualine, from the roles. Each mode gets its own role, chosen to
-- differ from the others in every colorscheme: normal keyword (the structure color), insert func,
-- terminal string, visual number, command type, replace error.
--
-- The mode and the position are solid blocks with dark text, so they read in peripheral vision
-- while the eye is on the code. The fill is the role color toned down toward the background
-- (FILL = how much of the role color is kept) so the blocks do not glare; the dark text stays
-- above 4.5:1 on every fill. Replace keeps the full error color: it is meant to be noticed.
local P = __ROLES__

local function blend(fg, bg, alpha)
  local function ch(i)
    local a = tonumber(fg:sub(i, i + 1), 16)
    local b = tonumber(bg:sub(i, i + 1), 16)
    return math.floor(math.min(math.max(0, alpha * a + (1 - alpha) * b), 255) + 0.5)
  end
  return ("#%02x%02x%02x"):format(ch(2), ch(4), ch(6))
end

P.panel = blend(P.surface, P.bg, 0.30)

local FILL = 0.75

local function mode(role, full)
  local bg = full and P[role] or blend(P[role], P.bg, FILL)
  return {
    a = { bg = bg, fg = P.bg, gui = "bold" },
    b = { bg = P.surface, fg = P[role] },
    c = { bg = P.panel, fg = P.fg },
  }
end

return {
  normal = mode("keyword"),
  insert = mode("func"),
  terminal = mode("string"),
  command = mode("type"),
  visual = mode("number"),
  replace = mode("error", true),
  inactive = {
    a = { bg = P.panel, fg = P.func },
    b = { bg = P.panel, fg = P.selection, gui = "bold" },
    c = { bg = P.panel, fg = P.fg_faint },
  },
}
