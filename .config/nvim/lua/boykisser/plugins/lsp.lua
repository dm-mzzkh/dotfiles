return {
  -- mason: lazy on its own commands, and pulled in as an LSP dependency below
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
    build = ":MasonUpdate",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- LSP: lspconfig + mason-lspconfig, loaded lazily when a real file is opened.
  -- mason and mason-lspconfig are dependencies so load order is deterministic
  -- (mason.setup -> mason-lspconfig.setup -> server enable).
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Глобальные настройки для всех серверов (регистрируем до enable)
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        on_attach = function(client, bufnr)
          local keymap = vim.keymap.set
          local opts = { buffer = bufnr, silent = true }

          keymap("n", "gd", vim.lsp.buf.definition, opts)
          keymap("n", "K", vim.lsp.buf.hover, opts)
          keymap("n", "gi", vim.lsp.buf.implementation, opts)
          keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
          keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          keymap("n", "gr", vim.lsp.buf.references, opts)

          -- <leader>ld, чтобы не конфликтовать с префиксом nvim-tree (<leader>e*)
          keymap("n", "<leader>ld", vim.diagnostic.open_float, opts)
          keymap("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
          keymap("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
          keymap("n", "<leader>q", vim.diagnostic.setloclist, opts)
        end,
      })

      -- Ставит нужные серверы и сам вызывает vim.lsp.enable (automatic_enable)
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright" },
      })

      vim.lsp.enable("pyright")
    end,
  },

  -- venv-selector
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
      "mfussenegger/nvim-dap-python",
      "nvim-telescope/telescope.nvim",
    },
    ft = "python",
    keys = {
      { ",v", "<cmd>VenvSelect<cr>" },
    },
    opts = {},
  },
}
