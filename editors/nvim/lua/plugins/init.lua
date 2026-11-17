return {
  -- Auto-closing of brackets and quotes is switched off entirely. To bring it back, delete
  -- `enabled = false` (NvChad's own spec then loads the plugin with its defaults).
  { "windwp/nvim-autopairs", enabled = false },

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

  -- Inline images in markdown. iTerm2 has no Kitty graphics protocol, so use
  -- Sixel, and only draw the image under the cursor since Sixel is slow.
  {
    "3rd/image.nvim",
    ft = { "markdown" },
    build = false, -- use the magick CLI instead of building the luarocks module
    opts = {
      backend = "sixel",
      processor = "magick_cli",
      tmux_show_only_in_active_window = true,
      integrations = {
        markdown = {
          only_render_image_at_cursor = true,
        },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    -- event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "python", "bash", "html", "css",
        "json", "yaml", "toml", "markdown", "markdown_inline",
        "rust", "latex", "c",
      },
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      code = { enabled = false },
    },
  },

  -- auto-install language servers via Mason
  {
    "williamboman/mason.nvim",
    lazy = false,
    opts = {
      ensure_installed = { "ltex-ls", "pyright", "lua-language-server", "ruff", "stylua", "rust-analyzer" },
    },
  },

  -- ltex dictionary & rule persistence (setup is called inside lspconfig on_attach)
  {
    "barreiroleo/ltex_extra.nvim",
    ft = { "tex", "plaintex", "markdown" },
  },

  -- LaTeX support
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_version_check = 0
      local is_mac = vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1
      vim.g.vimtex_view_method = is_mac and "skim" or "zathura"
      -- Reverse search (click in the PDF moves this Neovim's cursor): route vimtex's
      -- inverse-search call through a wrapper that talks to the running instance.
      vim.g.vimtex_callback_progpath = vim.fn.expand "~/.local/bin/nvim-inverse-search"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        aux_dir = ".aux",
        out_dir = "",
        callback = 1,
        continuous = 0, -- compile-on-save mode
        executable = "latexmk",
        options = {
          "-pdf",
          "-shell-escape",
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }
      vim.g.vimtex_syntax_enabled = 1
      vim.g.vimtex_quickfix_mode = 2     -- open quickfix on errors, not warnings
      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.tex_flavor = "latex"
    end,
  },

  -- vimtex completion source for citations, labels, etc.
  {
    "micangl/cmp-vimtex",
    ft = { "tex", "plaintex" },
  },

  -- unified completion config with spell & vimtex support
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "f3fora/cmp-spell",
      "micangl/cmp-vimtex",
    },
    opts = function(_, opts)
      local cmp = require "cmp"

      -- add spell source for markdown buffers
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          cmp.setup.buffer {
            sources = cmp.config.sources(
              vim.list_extend(vim.deepcopy(opts.sources or {}), {
                { name = "spell", keyword_length = 3 },
              })
            ),
          }
        end,
      })

      -- add vimtex & spell sources for LaTeX buffers
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "tex", "plaintex" },
        callback = function()
          cmp.setup.buffer {
            sources = cmp.config.sources(
              vim.list_extend(vim.deepcopy(opts.sources or {}), {
                { name = "vimtex" },
                { name = "spell", keyword_length = 3 },
              })
            ),
          }
        end,
      })

      return opts
    end,
  },
}
