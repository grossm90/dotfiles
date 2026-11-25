return {
	"stevearc/conform.nvim",
	opts = {},
	config = function()
		require("conform").setup({
			format_on_save = {
				timeout_ms = 5000,
                lsp_format = "fallback",
			},
			formatters_by_ft = {
				c = { "clang-format" },
				cpp = { "clang-format" },
				lua = function(bufnr)
					-- PICO-8 code is formatted by its own language server;
					-- stylua does not understand PICO-8's shorthand.
					if require("config.pico8").is_cart_buffer(bufnr) then
						return { lsp_format = "prefer" }
					end
					return { "stylua" }
				end,
				go = { "gofmt" },
				javascript = { "prettier" },
				typescript = { "prettier" },
			},
			formatters = {
				["clang-format"] = {
					prepend_args = { "-style=file", "-fallback-style=LLVM" },
				},
			},
		})

            vim.keymap.set("n", "<leader>f", function()
			require("conform").format({ bufnr = 0 })
		end)
	end,
}
