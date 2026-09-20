return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			ts.setup({})

			local function enable(buf, lang)
				vim.treesitter.start(buf, lang)
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local buf = args.buf
					local lang = vim.treesitter.language.get_lang(args.match)
					if not lang then
						return
					end
					-- Parser already installed: turn on highlight + indent
					if pcall(enable, buf, lang) then
						return
					end
					-- Otherwise try to install it, then enable
					ts.install({ lang }):await(function()
						if vim.api.nvim_buf_is_valid(buf) then
							pcall(enable, buf, lang)
						end
					end)
				end,
			})
		end,
	},
}
