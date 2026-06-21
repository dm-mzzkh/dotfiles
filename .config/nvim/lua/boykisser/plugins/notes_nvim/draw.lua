math.randomseed(os.time())

local M = {}

local cats = {
  {
    " /\\_/\\",
    "( o.o )",
    " > ^ <"
  },
  {
    "      /\\_/\\",
    " /\\  / o o \\",
    "//\\\\ \\~(*)~/",
    "`  \\/   ^ /",
    "   | \\|| ||",
    "   \\ '|| ||",
    "    \\)()-())"
  },
  {
    "   |\\---/|",
    "   | ,_, |",
    "    \\_`_/-..----.",
    " ___/ `   ' ,\"\"+ \\",
    "(__...'   __\\    |`.___.';",
    "  (_,...'(_,.`__)/'.....+"
  },
  {
    "             __..--''``---....___   _..._    __",
    " /// //_.-'    .-/\";  `        ``<._  ``.''_ `. / // /",
    "///_.-' _..--.'_    \\                    `( ) ) // //",
    "/ (_..-' // (< _     ;_..__               ; `' / ///",
    " / // // //  `-._,_)' // / ``--...____..-' /// / //"
  },
  {
    "       |\\      _,,,---,,_",
    "ZZZzz /,`.-'`'    -.  ;-;;,_",
    "     |,4-  ) )-,_. ,\\ (  `'-",
    "    '---''(_/--'  `-'\\_)"
  },
  {
    " _._     _,-'\"\"`-._",
    "(,-.`._,'(       |\\`-/|",
    "    `-.-' \\ )-`( , o o)",
    "          `-    \\`_`\"'-"
  }
}

function M.draw_cat()
  local cat = cats[math.random(#cats)]

  local buf = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1]

  for _, line in ipairs(cat) do
    vim.api.nvim_buf_set_lines(buf, row, row, false, { line })
    row = row + 1
  end
  vim.api.nvim_buf_set_lines(buf, row, row, false, { "" })
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
end

return M
