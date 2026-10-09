return {
  { "kaarmu/typst.vim", ft = "typst" },
  {
    "neovim/nvim-lspconfig",
    ft = "typst",
    config = function()
      vim.lsp.enable("tinymist")
    end,
  },
}
