return {
	'nvim-telescope/telescope.nvim', tag = '0.1.8',
	dependencies = { 'nvim-lua/plenary.nvim' },
	config = function()
		local builtin = require('telescope.builtin')

		-- "p" for project
		vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = "Find files" })
		vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = "Find files tracked by git" })
		vim.keymap.set('n', '<leader>ps', function()
			builtin.grep_string({ search = vim.fn.input("Grep > ") })
		end, { desc = "Search text in all files" })
		vim.keymap.set('n', '<leader>pb', builtin.buffers, { desc = "Open buffers" })
		vim.keymap.set('n', '<leader>vh', builtin.help_tags, { desc = "Search help" })
		vim.keymap.set('n', '<leader>vk', builtin.keymaps, { desc = "Search key mappings" })
	end,
}
