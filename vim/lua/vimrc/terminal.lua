local vim = vim
local api = vim.api
local fn = vim.fn
local bo = vim.bo
local cmd = vim.cmd
local M = {}
local utils = require "vimrc.utils"
local s_terminals = {}

function M.index_terminals(exclude_bufnr)
    s_terminals = {}
    local buffers = table.filter(fn.range(1, fn.bufnr('$')),
                                 function(value, key, _)
        return exclude_bufnr ~= key and fn.buflisted(key) == 1 and
                   bo[key].filetype == "terminal" and
                   api.nvim_buf_get_var(key, "terminal_closing") ~= true
    end)

    for index, bufnr in ipairs(buffers) do s_terminals[index] = bufnr end
end

function M.get_terminal_bufnr(nr)
    local bufnr = s_terminals[nr]
    if bufnr == nil then return -1 end

    return bufnr
end

function M.switch_to_terminal(index)
    local bufnr = M.get_terminal_bufnr(index)
    if bufnr == -1 then
        cmd("echohl Error")
        cmd("echo '[vimrc] Cannot find terminal buffer.'")
        cmd("echohl Normal")
        return
    end

    local current_bufnr = api.nvim_get_current_buf()
    local position = utils.find_open_window(bufnr)
    if position.tabnr ~= -1 then
        cmd(position.tabnr .. "tabnext")
        cmd(position.winnr .. "wincmd w")
    elseif bufnr ~= -1 then
        if bo[current_bufnr].filetype == "terminal" then
            cmd("vertical new | buffer " .. bufnr)
        else
            cmd("botright new | buffer " .. bufnr)
        end
    else
        cmd("echohl Error")
        cmd("echo '[vimrc] Cannot find terminal buffer.'")
        cmd("echohl Normal")
    end
end

return M
