require("nvchad.configs.lspconfig").defaults()

-- Configure ltex before enabling servers
vim.lsp.config("ltex", {
  filetypes = { "tex", "plaintex", "markdown" },
  root_markers = { ".git", ".latexmkrc", "Makefile" },
  settings = {
    ltex = {
      language = "en-US",
      enabled = { "latex", "markdown" },
      additionalRules = {
        enablePickyRules = true,
      },
      latex = {
        -- "dummy" makes ltex read the whole command as one noun, so the label key inside
        -- a cross-reference is not spell-checked. \ds is the Assignment 2 citation macro.
        commands = {
          ["\\ds{}"] = "dummy",
          ["\\cref{}"] = "dummy",
          ["\\Cref{}"] = "dummy",
        },
        environments = {},
      },
    },
  },
})

-- Attach ltex_extra for dictionary and rule persistence
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "ltex" then
      local ok, ltex_extra = pcall(require, "ltex_extra")
      if ok then
        ltex_extra.setup {
          load_langs = { "en-US" },
          init_check = true,
          path = vim.fn.expand "~/.config/nvim/ltex",
        }
      end
    end
  end,
})

-- Enable all configured language servers
local servers = { "html", "cssls", "rust_analyzer", "pyright", "lua_ls", "ltex" }
vim.lsp.enable(servers)
