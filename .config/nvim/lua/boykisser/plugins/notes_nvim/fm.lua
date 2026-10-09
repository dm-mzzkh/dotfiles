local M = {}

-- Frontmatter helpers: read/update YAML-ish frontmatter of a note buffer.

local FRONT_RE = "^%-%-%-%s*$"

function M.parse(bufnr)
  bufnr = bufnr or 0
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #lines == 0 or not lines[1]:match(FRONT_RE) then return {} end
  local meta = {}
  for i = 2, #lines do
    local l = lines[i]
    if l:match(FRONT_RE) then break end
    local k, v = l:match("^([%w_-]+):%s*(.*)$")
    if k then meta[k] = v end
  end
  return meta
end

function M.write(bufnr, meta)
  bufnr = bufnr or 0
  local lines = { "---" }
  for k, v in pairs(meta) do table.insert(lines, k .. ": " .. tostring(v)) end
  table.sort(lines)
  table.insert(lines, "---")
  local body = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  -- strip existing frontmatter
  if body[1] and body[1]:match(FRONT_RE) then
    for i = 2, #body do
      if body[i]:match(FRONT_RE) then body = vim.list_slice(body, i + 1, #body) break end
    end
  end
  for _, l in ipairs(body) do table.insert(lines, l) end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

return M
