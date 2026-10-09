local M = {}

M.cfg = {}

-- Setup global config for the notes plugin. Called once from vimwiki.lua.
function M.setup(opts)
  local defaults = {
    root = "~/Documents/vimwiki",
    templates_dir = "~/Documents/vimwiki/templates",
    default_template = "note.md",
    dirs = {},
  }
  for k, v in pairs(opts or {}) do defaults[k] = v end
  for k, v in pairs(defaults) do
    if type(v) == "string" then defaults[k] = vim.fn.expand(v) end
  end
  M.cfg = defaults
end

return M
