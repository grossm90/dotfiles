-- Tells PICO-8 code apart from ordinary Lua, so the right language server,
-- formatter and completion rules can be chosen for each file.
--
-- A buffer counts as PICO-8 code when it is a cart (.p8), or a .lua file in
-- the same folder as a cart (a module the cart pulls in with #include).

local M = {}

function M.is_cart_buffer(bufnr)
    if bufnr == nil or bufnr == 0 then
        bufnr = vim.api.nvim_get_current_buf()
    end

    -- Checked on every keystroke by the completion menu, so remember the answer.
    local cached = vim.b[bufnr].pico8_cart
    if cached ~= nil then
        return cached
    end

    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == "" then
        return false
    end

    local result = false
    if name:match("%.p8$") then
        result = true
    elseif name:match("%.lua$") then
        -- Look only in the file's own folder, never in subfolders.
        pcall(function()
            for entry, kind in vim.fs.dir(vim.fs.dirname(name)) do
                if kind ~= "directory" and entry:match("%.p8$") then
                    result = true
                    break
                end
            end
        end)
    end

    vim.b[bufnr].pico8_cart = result
    return result
end

-- The folder a cart and its modules live in.
function M.cart_dir(bufnr)
    return vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
end

return M
