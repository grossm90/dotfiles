require("config.lazy")
require("config.remap")

-- Transparent Background
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

-- Optional Settings
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

-- Make .p8 files use Lua filetype
vim.filetype.add({
  extension = {
    p8 = "lua",
  },
})

vim.api.nvim_create_autocmd({'BufNew', 'BufEnter'}, {
    pattern = { '*.p8' },
    callback = function(args)
        vim.lsp.start({
            name = 'pico8-ls',
            cmd = { 'pico8-ls', '--stdio' },
            root_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(args.buf)),
            -- Setup your keybinds in the on_attach function
            on_attach = on_attach,
        })
    end
})
