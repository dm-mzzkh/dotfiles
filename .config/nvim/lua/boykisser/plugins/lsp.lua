return {
  -- mason
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
	icons = {
	  package_installed = "✓",
	  package_pending = "➜",
	  package_uninstalled = "✗"
	}
      }
    },
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },

  -- mason-lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
	ensure_installed = { "pyright" },
	automatic_installation = true,
      })
    end,
  },

  -- новый LSP API
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Глобальные настройки для всех серверов
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

	  keymap("n", "<leader>e", vim.diagnostic.open_float, opts)
	  keymap("n", "[d", vim.diagnostic.goto_prev, opts)
	  keymap("n", "]d", vim.diagnostic.goto_next, opts)
	  keymap("n", "<leader>q", vim.diagnostic.setloclist, opts)
	end,
      })

      -- Прогружаем lspconfig, чтобы он прописал RTP серверов
      require("lspconfig")

      -- Запускаем нужные серверы
      vim.lsp.enable({ "pyright" })
    end,
  },

  -- CMP
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
	snippet = {
	  expand = function(args)
	    require("luasnip").lsp_expand(args.body)
	  end,
	},
	mapping = cmp.mapping.preset.insert({
	  ["<C-Space>"] = cmp.mapping.complete(),
	  ["<CR>"] = cmp.mapping.confirm({ select = true }),
	  ["<Tab>"] = cmp.mapping.select_next_item(),
	  ["<S-Tab>"] = cmp.mapping.select_prev_item(),
	}),
	sources = cmp.config.sources({
	  { name = "nvim_lsp" },
	  { name = "luasnip" },
	}, {
	  { name = "buffer" },
	  { name = "path" },
	}),
      })
    end,
  },

  -- venv-selector
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
      "mfussenegger/nvim-dap-python",
      { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
    },
    ft = "python",
    branch = "regexp",
    keys = {
      { ",v", "<cmd>VenvSelect<cr>" },
    },
    opts = {},
  }
}
