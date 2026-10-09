local M = {}

-- Expand template placeholders ($title $date $id $year $month $day).
function M.expand(text, info)
  local out = text:gsub("%$(%a+)", function(name)
    return info[name] or ""
  end)
  return out
end

-- Read a template file (falls back to empty doc when missing).
function M.load(cfg, template)
  local name = template or cfg.default_template
  local path = cfg.templates_dir .. "/" .. name
  local f = io.open(path, "r")
  if not f then return "" end
  local text = f:read("*a")
  f:close()
  return text
end

-- Build note filename from title: "My long title!" -> 20261009151203_my_long_title.md
function M.slugify(title)
  local slug = title:lower():gsub("[^%w%s]", ""):gsub("%s+", "_")
  return slug ~= "" and slug or "untitled"
end

return M
