return {
  {
    "neovim/nvim-lspconfig",
    ft = "c",
    config = function()
      vim.lsp.config("clangd", {
        filetypes = { "c", "cpp", "objc", "objcpp" },
      })
      vim.lsp.enable("clangd")
    end,
  },
}
