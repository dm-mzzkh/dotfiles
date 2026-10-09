-- Smoke test: module loads + cfg defaults sane.
-- Run: nvim --headless -l tests/smoke.lua
local ok, err = pcall(function()
  local notemeta = require("boykisser.plugins.notes_nvim.notemeta")
  notemeta.setup({ root = "/tmp/vimwiki_test" })
  assert(notemeta.cfg.root == "/tmp/vimwiki_test", "cfg.root not stored")

  local tmpl = require("boykisser.plugins.notes_nvim.tmpl")
  assert(tmpl.slugify("My long title!") == "my_long_title", "slugify broken")
  local text = tmpl.expand("id=$id t=$title d=$date unknown=$foo", {
    id = "x", title = "T", date = "D",
  })
  assert(text == "id=x t=T d=D unknown=", "expand broken")

  local id = require("boykisser.plugins.notes_nvim.id").generate()
  assert(#id == 17, "id length wrong: " .. id)

  local fm = require("boykisser.plugins.notes_nvim.fm")
  assert(type(fm.parse) == "function" and type(fm.write) == "function", "fm api missing")
end)
if not ok then error(err) end
print("smoke: OK")
