-- Highlights TODO, FIXME, NOTE and similar comments in code, and lists them
-- across the project. The counterpart of Todo+'s "embedded todos" view.
return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        require("todo-comments").setup({})

        -- "pt" for project todos
        vim.keymap.set("n", "<leader>pt", "<cmd>TodoTelescope<CR>", { desc = "Find todo comments in the project" })
        vim.keymap.set("n", "]t", function()
            require("todo-comments").jump_next()
        end, { desc = "Next todo comment" })
        vim.keymap.set("n", "[t", function()
            require("todo-comments").jump_prev()
        end, { desc = "Previous todo comment" })
    end,
}
