-- ~/.config/nvim/lua/plugins/db.lua
return {
  {
    "tpope/vim-dadbod",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",        -- UI for browsing schemas/tables
      "kristijanhusak/vim-dadbod-completion" -- completion in queries
    },
    cmd = {
      "DB", "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer"
    },
    init = function()
      -- Optional: make completion work with nvim-cmp
      vim.g.db_ui_use_nerd_fonts = 1
    end,
    config = function()
      -- Example: open DBUI with <leader>du
      vim.keymap.set("n", "<leader>du", "<cmd>DBUI<CR>", { desc = "Toggle DB UI" })
    end,
  },
}
