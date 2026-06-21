return {
{
   'vimwiki/vimwiki',
   event = "VeryLazy",
   init = function () --replace 'config' with 'init'
      vim.g.vimwiki_list = {
	 {path = '~/Documents/vimwiki/', syntax = 'markdown', ext = '.md'},
	 {path = '~/programming/progwiki/', syntax = 'markdown', ext = '.md'},
      }
   end,

},
{
  dir  = vim.fn.stdpath("config")
  .. "/lua/boykisser/plugins/notes_nvim",
  name = "notes-nvim",
  keys = {
    {
      "<Leader>nn",
      function() require('boykisser.plugins.notes_nvim.create_note').create_note() end,
      desc = "Create new note",
    },
    {
      "<Leader>nc",
      function() require('boykisser.plugins.notes_nvim.draw').draw_cat() end,
      desc = "Draw cat ASCII",
    },
    {
      "m",
      ":<C-u>lua require('boykisser.plugins.notes_nvim.createmdlink').create_markdown_link()<CR>",
      mode = "v",
      noremap = true,
      silent = true,
      nowait = true,
      desc = "Create md link",
    },
  },
}
}
