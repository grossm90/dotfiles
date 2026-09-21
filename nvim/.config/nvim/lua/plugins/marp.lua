return {
  "nwiizo/marp.nvim",
  config = function()
    require("marp").setup({
      theme_set = { vim.fn.expand("~/.local/marp/themes") },
      allow_local_files = true,
    })
  end,
}
