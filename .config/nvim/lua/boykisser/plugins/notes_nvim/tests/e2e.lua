-- E2E-ish: create a note via new.lua into a temp root, check file + frontmatter.
-- Run: nvim --headless -l tests/e2e.lua
local root = "/tmp/notes_e2e_" .. os.time()
local notemeta = require("boykisser.plugins.notes_nvim.notemeta")
notemeta.setup({
  root = root,
  templates_dir = root .. "/templates",
  default_template = "note.md",
  dirs = { diary = "journal" },
})
-- ponytail: minimal fake templates dir so tmpl.load has something to read
vim.fn.mkdir(root .. "/templates", "p")
local f = io.open(root .. "/templates/note.md", "w")
f:write("---\nid: $id\n---\n# $title\n")
f:close()

-- stub vim.ui.input so new() proceeds without interaction
local t = vim.fn.expand("~/database/main")
assert(t ~= "", "home expand works")
local new = require("boykisser.plugins.notes_nvim.new")
local old_input = vim.ui.input
vim.ui.input = function(opts, cb) cb("Test note") end

-- run into a scratch config root by overriding notemeta cfg after setup
notemeta.cfg.root = root

new.new(require("boykisser.plugins.notes_nvim.notemeta").cfg)
vim.ui.input = old_input

-- find what got written
local files = vim.fn.glob(root .. "/*_test_note.md", false, true)
assert(#files == 1, "expected 1 note, got " .. tostring(#files))
local content = table.concat(vim.fn.readfile(files[1]), "\n")
assert(content:find("%-%-%-"), "no frontmatter")
assert(content:find("# Test note"), "no title header")
assert(content:find("id: %d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d"), "no id line")

-- cleanup
os.remove(root .. "/templates/note.md")
os.remove(files[1])
print("e2e: OK")
