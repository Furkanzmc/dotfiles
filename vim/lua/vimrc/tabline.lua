local vim = vim
local api = vim.api
local fn = vim.fn
local wo = vim.wo
local g = vim.g
local utils = require "vimrc.utils"
local buffers = require "vimrc.buffers"
local M = {}

local function get_bufname(bufnr)
    local bufname = fn.bufname(bufnr)
    local processed = ""
    if bufname == "" then
        processed = "[No Name]"
    else
        processed = fn.fnamemodify(bufname, ':t')
        if processed == "" then processed = fn.fnamemodify(bufname, ':~') end
    end

    return processed
end

function M.tablabel(tabnr)
    local label = {}
    local buflist = fn.tabpagebuflist(tabnr)
    local winnr = fn.tabpagewinnr(tabnr)
    local bufname = get_bufname(buflist[winnr])
    local modified_count = buffers.get_modified_buf_count(tabnr)

    table.insert(label, tabnr)
    table.insert(label, ". ")
    table.insert(label, bufname)
    if modified_count > 0 then
        table.insert(label, " [+" .. modified_count .. "]")
    end

    local current_tabnr = fn.tabpagenr()
    if tabnr < current_tabnr - 1 or tabnr > current_tabnr then
        table.insert(label, " |")
    else
        table.insert(label, " ")
    end

    return table.concat(label)
end

function M.init()
    local s = {}
    local last_tabnr = fn.tabpagenr('$')
    for tabnr in utils.range(last_tabnr) do
        -- Select the highlighting
        if tabnr == fn.tabpagenr() then
            table.insert(s, '%#TabLineSel#')
        else
            table.insert(s, '%#TabLine#')
        end

        table.insert(s, ' %' .. tabnr .. 'T')

        -- the label is made by tablabel()
        table.insert(s, '%{luaeval("' .. "require'vimrc.tabline'" ..
                         '.tablabel(' .. tabnr .. ')")}')
    end

    -- after the last tab fill with TabLineFill and reset tab page nr
    table.insert(s, '%#TabLineFill#%T')

    return table.concat(s)
end

return M
