require "nvchad.autocmds"

vim.opt.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermLeave", "WinEnter" }, {
  command = "checktime",
})

-- Claude edits files from outside Neovim (often from a terminal split), where
-- CursorHold does not fire. Poll once a second in normal/visual mode and reload
-- unmodified buffers that changed on disk.
local autoread_timer = vim.uv.new_timer()
autoread_timer:start(1000, 1000, vim.schedule_wrap(function()
  local mode = vim.api.nvim_get_mode().mode
  if mode:sub(1, 1) == "n" or mode:sub(1, 1) == "v" then
    pcall(vim.cmd, "silent! checktime")
  end
end))

-- Spell checking is on everywhere (options.lua); a terminal is the one place it only adds noise.
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.spell = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "plaintex" },
  callback = function()
    vim.opt_local.textwidth = 0      -- no hard wrapping
    vim.opt_local.conceallevel = 2
    vim.g.tex_conceal = "abdmgs"     -- hide \textbf{} wrappers etc.; keep the text
    -- show \item as a bullet
    vim.cmd([[syntax match texItemBullet "\\item" conceal cchar=•]])
    -- let vimtex handle syntax highlighting instead of treesitter
    pcall(vim.treesitter.stop)
  end,
})

-- Compile on save and forward search to cursor position in viewer
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.tex" },
  callback = function()
    if vim.fn.exists(":VimtexCompileSS") == 2 then
      -- silent: otherwise "Compiler started" plus the "written" line need a hit-enter
      pcall(vim.cmd, "silent! VimtexCompileSS")
      pcall(vim.cmd, "silent! VimtexView")
    end
  end,
})
