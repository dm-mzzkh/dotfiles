local M = {}

-- Unique note id: timestamp + counter suffix so two notes in the same second
-- never collide.
function M.generate()
  local time = os.date("%Y%m%d%H%M%S")
  local seq = 1
  local path = vim.fn.stdpath("data") .. "/notes_id_seq"
  local f = io.open(path, "r")
  if f then
    local last = f:read("*l")
    f:close()
    if last and vim.startswith(last, time) then seq = tonumber(last:sub(-3)) + 1 end
  end
  f = io.open(path, "w")
  if f then f:write(string.format("%s%03d", time, seq)) f:close() end
  return string.format("%s%03d", time, seq)
end

return M
