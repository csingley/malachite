-- UI states for judging a Neovim theme. Open a sample with preview.sh (or
--   nvim -c 'luafile ui-states.lua' sample.py)
-- and switch states with  :Scene <name>  (tab-completes)  or  <F2>  to step through them.
-- Statusline modes need no scene: press i, v, V, R, : and watch the statusline.
local ns = vim.api.nvim_create_namespace("theme-scenes")
local scenes, order = {}, {}

local function find(plain)
  for i, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    if line:find(plain, 1, true) then
      return i
    end
  end
end

local function reset()
  vim.diagnostic.reset(ns, 0)
  vim.cmd("nohlsearch")
  vim.wo.list, vim.wo.spell = false, false
  vim.wo.foldmethod = "manual"
  vim.cmd("silent! normal! zE")
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
  vim.cmd("stopinsert")
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end

local function add(name, fn)
  scenes[name] = fn
  order[#order + 1] = name
end

-- Errors, warnings, info and hints: sign, underline and virtual text for each. The sample
-- files mark their lines with "DIAG: <level> (<message>)".
add("diagnostics", function()
  local sev = vim.diagnostic.severity
  local levels = { error = sev.ERROR, warn = sev.WARN, info = sev.INFO, hint = sev.HINT }
  local list = {}
  for i, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    local kind, msg = line:match("DIAG: (%a+)%s+%((.-)%)")
    if kind and levels[kind] then
      list[#list + 1] = { lnum = i - 1, col = 0, end_col = #line, severity = levels[kind], message = msg, source = "theme" }
    end
  end
  vim.diagnostic.config({ virtual_text = true, underline = true, signs = true }, ns)
  vim.diagnostic.set(ns, 0, list)
  vim.api.nvim_win_set_cursor(0, { math.max((find("DIAG: error") or 1) - 3, 1), 0 })
end)

-- Search matches: all matches, plus the current one under the cursor.
add("search", function()
  vim.fn.setreg("/", "retry")
  vim.o.hlsearch = true
  vim.cmd("let v:hlsearch = 1")
  vim.api.nvim_win_set_cursor(0, { find("SEARCH:") or 1, 0 })
  vim.fn.search("retry")
end)

-- A linewise visual selection.
add("visual", function()
  vim.api.nvim_win_set_cursor(0, { find("TODO:") or 1, 0 })
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("V6j", true, false, true), "n", false)
end)

-- The cursor on a bracket: its partner is highlighted.
add("bracket", function()
  vim.api.nvim_win_set_cursor(0, { find("retry(") or find("check_host() {") or 1, 0 })
  vim.cmd("normal! f(")
end)

-- The completion popup menu, with several kinds of entry.
add("completion", function()
  vim.cmd("normal! G")
  vim.cmd("startinsert!")
  vim.defer_fn(function()
    vim.fn.complete(vim.fn.col("."), {
      { word = "schedule", kind = "Function", menu = "[lsp]", info = "schedule(jobs, pool=None)" },
      { word = "scheduler", kind = "Class", menu = "[lsp]" },
      { word = "SCHEDULE_MAX", kind = "Constant", menu = "[buf]" },
      { word = "sched_state", kind = "Variable", menu = "[buf]" },
      { word = "select", kind = "Keyword", menu = "[kw]" },
    })
  end, 250)
end)

-- A floating window with markdown (a hover, as an LSP would show).
add("float", function()
  vim.lsp.util.open_floating_preview({
    "**retry**(times: int = 3)",
    "",
    "```python",
    "def retry(times: int = MAX_RETRIES): ...",
    "```",
    "A *decorator factory*. See `MAX_RETRIES` and [the docs](http://example.com).",
  }, "markdown", { border = "rounded" })
end)

-- Folded code.
add("folds", function()
  vim.wo.foldmethod = "indent"
  vim.cmd("normal! zM")
  vim.api.nvim_win_set_cursor(0, { find("class State") or find("usage()") or 1, 0 })
end)

-- Whitespace characters.
add("whitespace", function()
  vim.wo.list = true
  vim.opt.listchars = { tab = "» ", trail = "·", space = "·", extends = ">", precedes = "<" }
end)

-- Spell checking (comments and strings only, as in code).
add("spell", function()
  vim.wo.spell = true
end)

local current = 0
local function run(name)
  if not scenes[name] then
    vim.notify("no scene: " .. tostring(name), vim.log.levels.WARN)
    return
  end
  reset()
  scenes[name]()
  for i, n in ipairs(order) do
    if n == name then
      current = i
    end
  end
  vim.notify("scene: " .. name)
end

vim.api.nvim_create_user_command("Scene", function(o)
  run(o.args)
end, { nargs = 1, complete = function() return order end })
vim.api.nvim_create_user_command("Scenes", function() vim.notify(table.concat(order, " ")) end, {})
vim.keymap.set("n", "<F2>", function()
  run(order[current % #order + 1])
end, { desc = "next theme scene" })

-- On open: diagnostics and a search, the two most common states together.
vim.defer_fn(function()
  scenes.diagnostics()
  vim.fn.setreg("/", "retry")
  vim.o.hlsearch = true
  vim.cmd("let v:hlsearch = 1")
  vim.notify(":Scene <name>, or F2 to step")
end, 300)
