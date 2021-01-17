local vim = vim
local cmd = vim.cmd
local M = {}

function M.find_open_window(buffer)
    local current_tab = vim.fn.tabpagenr()
    local last_tab = vim.fn.tabpagenr('$')

    for tabnr = 1, last_tab, 1 do
        local buffers = vim.fn.tabpagebuflist(tabnr)
        for winnr, bufnr in ipairs(buffers) do
            if buffer == bufnr then
                return {tabnr = tabnr, winnr = winnr}
            end
        end
    end

    return {tabnr = -1, winnr = -1}
end

function M.switch_to_buffer(bufnr)
    local position = M.find_open_window(bufnr)
    if position.tabnr ~= -1 then
        cmd(position.tabnr .. "tabnext")
        cmd(position.winnr .. "wincmd w")
    elseif bufnr ~= -1 then
        cmd("botright new | buffer " .. bufnr)
    else
        cmd("echohl Error")
        cmd("echo '[vimrc] Cannot find terminal buffer.'")
        cmd("echohl Normal")
    end
end

return M
