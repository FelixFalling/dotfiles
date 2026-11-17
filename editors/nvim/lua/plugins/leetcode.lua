-- leetcode.nvim - browse, solve and submit without leaving the editor.
--
-- Only loads when nvim is started as `nvim leetcode`, so it costs nothing
-- on an ordinary edit. Problem statements and question data are cached to
-- disk once fetched, which is what makes this usable over a flaky hotel
-- connection: a problem you have already opened stays readable.
local leet_arg = "leetcode"

return {
  {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    lazy = leet_arg ~= vim.fn.argv()[1],
    opts = {
      arg = leet_arg,
      lang = "python3",
      storage = {
        home = vim.fn.expand "~/leetcode",
        cache = vim.fn.stdpath "cache" .. "/leetcode",
      },
      console = {
        open_on_runcode = true,
      },
      description = {
        position = "left",
        width = "40%",
      },
    },
  },
}
