-- Headless check that :new produces a note through the create_note wrapper.
-- Run: nvim --headless -l tests/newnote.lua
local root = "/tmp/notes_newnote_" .. os.time()
local notemeta = require("boykisser.plugins.notes_nvim.notemeta")
notemeta.setup({ root = root, templates_dir = root, default_template = "note.md" })
notemeta.cfg.root = root

vim.ui.input = function(_, cb) cb("wrapper check") end
require("boykisser.plugins.notes_nvim.create_note").create_note()

local ft = vim.fn.glob(root .. "/*wrapper_check.md", false, true)
assert(#ft == 1, "wrapper did not create note: " .. vim.inspect(ft))
print("newnote: OK")
