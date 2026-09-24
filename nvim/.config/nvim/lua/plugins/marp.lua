return {
  "nwiizo/marp.nvim",
  config = function()
    require("marp").setup({
      theme_set = { vim.fn.expand("~/.local/marp/themes") },
      allow_local_files = true,
      browser_kind = "firefox",
      browser_path = "/usr/bin/zen-browser",
    })
  end,
}
