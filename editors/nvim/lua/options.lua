require "nvchad.options"

-- If headless / remote without Wayland/X11 or tmux, use OSC 52 for clipboard sync
if vim.env.WAYLAND_DISPLAY == nil and vim.env.DISPLAY == nil and vim.env.TMUX == nil then
  vim.g.clipboard = "osc52"
end

-- Spell checking and soft wrapping at word boundaries in every buffer. In code, treesitter
-- limits the spell check to comments and strings.
vim.opt.spell = true
vim.opt.spelllang = "en_us"
vim.opt.wrap = true
vim.opt.linebreak = true
