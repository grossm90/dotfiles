-- Editor settings come first, before the plugins load. On a launch where the
-- plugin manager opens its install window, settings applied afterwards (line
-- numbers in particular) can land on that window instead of the editor.
vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

vim.env.FIREFOX_PATH = "/usr/bin/zen-browser"

-- PICO-8 carts (.p8) are highlighted as Lua. Their language server is set up
-- in lua/plugins/lsp.lua.
vim.filetype.add({
  extension = {
    p8 = "lua",
  },
})

-- New files in a cart's folder are saved straight away (see lua/config/pico8.lua).
require("config.pico8").setup()

-- Plugins and custom keys
require("config.lazy")
require("config.remap")

-- Transparent background. Must come after the plugins so the colour theme
-- does not override it.
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
