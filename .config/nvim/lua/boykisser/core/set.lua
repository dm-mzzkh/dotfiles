local set = vim.opt

-- disable netrw early so nvim-tree is the only file explorer
-- (must run at startup, before netrw's plugin loads)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

set.clipboard = "unnamedplus"

set.shiftwidth=2

set.nu = true
set.relativenumber = true

vim.opt.colorcolumn = "81"

--set.hlsearch = false
set.incsearch = true

set.scrolloff = 8

vim.keymap.set('n', 'Q', ':q<CR>', {noremap = true, silent = true})
