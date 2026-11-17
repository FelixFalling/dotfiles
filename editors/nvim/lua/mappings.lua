require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- LaTeX (vimtex) mappings
map("n", "<leader>lc", "<cmd>VimtexCompile<cr>",    { desc = "LaTeX compile (toggle)" })
map("n", "<leader>lv", "<cmd>VimtexView<cr>",       { desc = "LaTeX view PDF" })
map("n", "<leader>le", "<cmd>VimtexErrors<cr>",     { desc = "LaTeX errors" })
map("n", "<leader>lt", "<cmd>VimtexTocToggle<cr>",  { desc = "LaTeX TOC toggle" })
map("n", "<leader>lk", "<cmd>VimtexStop<cr>",       { desc = "LaTeX stop compile" })
map("n", "<leader>lK", "<cmd>VimtexClean<cr>",      { desc = "LaTeX clean aux files" })

-- q no longer starts macro recording (kept hitting it by accident); Q is disabled too
map({ "n", "x" }, "q", "<Nop>", { desc = "disabled: macro recording" })
map({ "n", "x" }, "Q", "<Nop>", { desc = "disabled: replay macro" })
