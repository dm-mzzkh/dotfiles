local M = {}

-- Main note creation flow: template -> title -> dir -> id + frontmatter.
function M.new(cfg)
  cfg = cfg or require("boykisser.plugins.notes_nvim.notemeta").cfg

  -- detect diary: if input looks like "journal/" prefix, use dirs.diary
  vim.ui.input({ prompt = "Note title: " }, function(title)
    if not title or title == "" then return end

    local is_diary = false
    if title:match("^journal/") then
      is_diary = true
      title = title:sub(9)
    elseif title:match("^diary/") then
      is_diary = true
      title = title:sub(7)
    end

    local dir = is_diary and (cfg.root .. "/" .. (cfg.dirs.diary or "journal")) or cfg.root
    vim.fn.mkdir(dir, "p")

    local id = require("boykisser.plugins.notes_nvim.id").generate()
    local stem = require("boykisser.plugins.notes_nvim.tmpl").slugify(title)
    local path = string.format("%s/%s_%s.md", dir, id, stem)

    local info = {
      id = id,
      title = title,
      date = os.date("%Y-%m-%d"),
      year = os.date("%Y"),
      month = os.date("%m"),
      day = os.date("%d"),
    }

    local template = require("boykisser.plugins.notes_nvim.tmpl").load(cfg, is_diary and "diary.md" or nil)
    local text = require("boykisser.plugins.notes_nvim.tmpl").expand(template, info)

    vim.fn.writefile(vim.split(vim.trim(text), "\n"), path)
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  end)
end

return M
