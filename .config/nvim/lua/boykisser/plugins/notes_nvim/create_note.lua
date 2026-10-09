local M = {}

-- Thin wrapper kept for backwards compatibility.
-- The real flow lives in new.lua (template -> title -> dir -> id + frontmatter).
function M.create_note()
  require("boykisser.plugins.notes_nvim.new").new(
    require("boykisser.plugins.notes_nvim.notemeta").cfg
  )
end

return M
