return {
  {
    "sheng-tse/jupynvim",
    lazy = false,
    build = function(plugin)
      local install = loadfile(plugin.dir .. "/lua/jupynvim/install.lua")()
      install.run(plugin)
    end,
    config = function()
      require("jupynvim").setup({
        log_level = "info",
        image_renderer = "placeholder",
      })
    end,
  },

  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "python", "bash", "html", "css",
        "json", "yaml", "toml", "markdown",
      },
    },
  },
}
