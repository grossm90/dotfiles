local root_files = {
  '.luarc.json',
  '.luarc.jsonc',
  '.luacheckrc',
  '.stylua.toml',
  'stylua.toml',
  'selene.toml',
  'selene.yml',
  '.git',
}

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        -- NOTE: this second conform.setup() call resets conform's autocommands,
        -- which switches off the format_on_save set in plugins/conform.lua.
        -- Delete this block to turn format-on-save back on.
        require("conform").setup({
            formatters_by_ft = {
            }
        })
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local pico8 = require("config.pico8")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        -- Settings for every language server.
        vim.lsp.config("*", {
            capabilities = capabilities,
        })

        -- Per-server settings. These only take effect for servers that are
        -- installed (see :Mason); mason-lspconfig switches those on itself.
        vim.lsp.config("lua_ls", {
            -- The general Lua server stays out of PICO-8 code, which it would
            -- flag as full of errors. Everywhere else it starts as usual.
            root_dir = function(bufnr, on_dir)
                if pico8.is_cart_buffer(bufnr) then
                    return
                end
                on_dir(vim.fs.root(bufnr, root_files))
            end,
            settings = {
                Lua = {
                    format = {
                        enable = true,
                        -- Put format options here
                        -- NOTE: the value should be STRING!!
                        defaultConfig = {
                            indent_style = "space",
                            indent_size = "2",
                        }
                    },
                }
            }
        })

        -- PICO-8: carts (.p8) and the .lua modules beside them. Both have the
        -- "lua" file type here, so the folder decides, not the file type.
        vim.lsp.config("pico8_ls", {
            filetypes = { "lua" },
            -- The server only formats documents labelled with its own
            -- language names; Neovim would otherwise send "lua".
            get_language_id = function(bufnr)
                if vim.api.nvim_buf_get_name(bufnr):match("%.p8$") then
                    return "pico-8"
                end
                return "pico-8-lua"
            end,
            root_dir = function(bufnr, on_dir)
                if pico8.is_cart_buffer(bufnr) then
                    on_dir(pico8.cart_dir(bufnr))
                end
            end,
        })

        vim.lsp.config("zls", {
            root_markers = { ".git", "build.zig", "zls.json" },
            settings = {
                zls = {
                    enable_inlay_hints = true,
                    enable_snippets = true,
                    warn_style = true,
                },
            },
        })
        vim.g.zig_fmt_parse_errors = 0
        vim.g.zig_fmt_autosave = 0

        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "pico8_ls",
            },
            -- stylua can run as a language server, and Mason would switch
            -- it on for every Lua file, PICO-8 code included. It is used
            -- as a plain formatter instead (plugins/conform.lua).
            automatic_enable = {
                exclude = { "stylua" },
            },
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            enabled = function()
                -- nvim-cmp's own defaults: off in prompts and during macros
                if vim.bo.buftype == "prompt" then
                    return false
                end
                if vim.fn.reg_recording() ~= "" or vim.fn.reg_executing() ~= "" then
                    return false
                end

                -- In PICO-8 code, stay quiet inside comments and strings.
                if pico8.is_cart_buffer(0) then
                    local context = require("cmp.config.context")
                    if context.in_treesitter_capture("comment")
                        or context.in_syntax_group("Comment")
                        or context.in_treesitter_capture("string")
                        or context.in_syntax_group("String") then
                        return false
                    end
                end

                return true
            end,
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                -- shows a function's parameters while you type its arguments
                { name = 'nvim_lsp_signature_help' },
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
