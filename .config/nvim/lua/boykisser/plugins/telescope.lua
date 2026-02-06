-- telescope.lua

-- compat for nvim 0.10
if vim.treesitter
  and vim.treesitter.language
  and vim.treesitter.language.get_lang
  and not vim.treesitter.language.ft_to_lang
then
  vim.treesitter.language.ft_to_lang =
    vim.treesitter.language.get_lang
end

return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    },
    config = function()
      local builtin = require('telescope.builtin')

      vim.keymap.set('n', '<leader>ff', builtin.find_files)
      vim.keymap.set('n', '<leader>fg', builtin.live_grep)
      vim.keymap.set('n', '<leader>fb', builtin.buffers)
      vim.keymap.set('n', '<leader>fs', builtin.grep_string)

      require('telescope').setup {
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      }

      require('telescope').load_extension('fzf')
    end,
  },
}
