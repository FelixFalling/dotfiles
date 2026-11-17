-- GitHub Copilot inline suggestions (grey ghost text while typing).
-- First use: run :Copilot auth and sign in with GitHub.
-- Alt-l accepts the suggestion, Alt-w one word, Alt-] / Alt-[ cycle, Ctrl-] dismisses.
-- Tab is left alone because nvim-cmp uses it for the completion menu.
return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<M-l>",
          accept_word = "<M-w>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      -- copilot.lua switches these off by default; turn on the ones written here
      filetypes = {
        tex = true,
        plaintex = true,
        markdown = true,
        gitcommit = false,
        ["*"] = true,
      },
    },
  },
}
