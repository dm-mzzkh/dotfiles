local set = vim.opt

set.clipboard = "unnamedplus"

set.shiftwidth=2

set.nu = true
set.relativenumber = true

vim.opt.colorcolumn = "81"

--set.hlsearch = false
set.incsearch = true

set.scrolloff = 8

vim.keymap.set('n', 'Q', ':q<CR>', {noremap = true, silent = true})
