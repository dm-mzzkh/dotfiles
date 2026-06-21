-- telescope.lua

-- compat for nvim 0.10 (and restores ft_to_lang removed in 0.11+)
-- runs at startup when this spec module is read, before any plugin uses it
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
    cmd = "Telescope",
    keys = {
      { '<leader>ff', function() require('telescope.builtin').find_files() end, desc = "Find files" },
      { '<leader>fg', function() require('telescope.builtin').live_grep() end, desc = "Live grep" },
      { '<leader>fb', function() require('telescope.builtin').buffers() end, desc = "Buffers" },
      { '<leader>fs', function() require('telescope.builtin').grep_string() end, desc = "Grep string" },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    },
    config = function()
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
