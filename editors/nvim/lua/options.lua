require "nvchad.options"

-- If headless / remote without Wayland/X11 or tmux, use OSC 52 for clipboard sync
if vim.env.WAYLAND_DISPLAY == nil and vim.env.DISPLAY == nil and vim.env.TMUX == nil then
  vim.g.clipboard = "osc52"
end
