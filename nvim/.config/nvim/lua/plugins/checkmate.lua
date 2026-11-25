-- Todo lists in the style of the VS Code Todo+ extension.
--
-- Files are saved as ordinary Markdown checkboxes ("- [ ]", "- [x]"), so
-- they also render as checklists on GitHub. The symbols below are only how
-- Neovim draws them.
return {
    "bngarren/checkmate.nvim",
    version = "~0.12.0", -- the plugin is pre-1.0; stay on 0.12.x
    ft = "markdown",

    init = function()
        -- Checkmate only switches on in Markdown buffers. Todo files often
        -- have no ".md" ending, so tell Neovim that these are Markdown too.
        vim.filetype.add({
            filename = {
                TODO = "markdown",
                todo = "markdown",
            },
            extension = {
                todo = "markdown",
            },
        })
    end,

    opts = {
        -- Which files count as todo lists (these are the plugin's defaults):
        -- TODO, todo, TODO.md, todo.md, *.todo, *.todo.md

        todo_states = {
            unchecked = { marker = "☐" },
            checked = { marker = "✔" },
            -- Saved to disk as "- [c]". Counts as finished, so it is
            -- included in the done/total count and gets archived.
            cancelled = {
                marker = "✘",
                markdown = "c",
                type = "complete",
                order = 3,
            },
        },

        -- Setting `keys` replaces the plugin's whole list, so the defaults
        -- are repeated here. Only <leader>Tx is an addition.
        keys = {
            ["<leader>Tt"] = {
                rhs = "<cmd>Checkmate toggle<CR>",
                desc = "Toggle todo item",
                modes = { "n", "v" },
            },
            ["<leader>Tc"] = {
                rhs = "<cmd>Checkmate check<CR>",
                desc = "Mark todo done",
                modes = { "n", "v" },
            },
            ["<leader>Tu"] = {
                rhs = "<cmd>Checkmate uncheck<CR>",
                desc = "Mark todo not done",
                modes = { "n", "v" },
            },
            ["<leader>Tx"] = {
                rhs = "<cmd>lua require('checkmate').toggle('cancelled')<CR>",
                desc = "Mark todo cancelled",
                modes = { "n", "v" },
            },
            ["<leader>T="] = {
                rhs = "<cmd>Checkmate cycle_next<CR>",
                desc = "Cycle todo to the next state",
                modes = { "n", "v" },
            },
            ["<leader>T-"] = {
                rhs = "<cmd>Checkmate cycle_previous<CR>",
                desc = "Cycle todo to the previous state",
                modes = { "n", "v" },
            },
            ["<leader>Tn"] = {
                rhs = "<cmd>Checkmate create<CR>",
                desc = "Create todo item",
                modes = { "n", "v" },
            },
            ["<leader>Tr"] = {
                rhs = "<cmd>Checkmate remove<CR>",
                desc = "Turn todo back into plain text",
                modes = { "n", "v" },
            },
            ["<leader>TR"] = {
                rhs = "<cmd>Checkmate remove_all_metadata<CR>",
                desc = "Remove all @tags from a todo",
                modes = { "n", "v" },
            },
            ["<leader>Ta"] = {
                rhs = "<cmd>Checkmate archive<CR>",
                desc = "Archive finished todos",
                modes = { "n" },
            },
            ["<leader>TF"] = {
                rhs = "<cmd>Checkmate select_todo<CR>",
                desc = "Pick a todo from this file",
                modes = { "n" },
            },
            ["<leader>Tv"] = {
                rhs = "<cmd>Checkmate metadata select_value<CR>",
                desc = "Change the value of the @tag under the cursor",
                modes = { "n" },
            },
            ["<leader>T]"] = {
                rhs = "<cmd>Checkmate metadata jump_next<CR>",
                desc = "Jump to the next @tag",
                modes = { "n" },
            },
            ["<leader>T["] = {
                rhs = "<cmd>Checkmate metadata jump_previous<CR>",
                desc = "Jump to the previous @tag",
                modes = { "n" },
            },
        },
    },
}
