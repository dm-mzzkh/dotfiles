local M = {}

function M.create_note()
  -- Define the directory where files will be stored (expanded so we can mkdir)
  local storage_path = vim.fn.expand("~/Documents/vimwiki/notes/")

  -- Make sure the directory exists, otherwise :write would fail (E212)
  vim.fn.mkdir(storage_path, "p")

  -- Generate filename from current date and time
  local filename = os.date("%Y%m%d%H%M%S") .. ".md"

  -- Create full file path
  local full_path = storage_path .. filename

  -- Open file in a new buffer
  vim.cmd("edit " .. vim.fn.fnameescape(full_path))
end

return M
