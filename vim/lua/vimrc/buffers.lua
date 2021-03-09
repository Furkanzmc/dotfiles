local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local g = vim.g
local b = vim.b
local bo = vim.bo
local wo = vim.wo
local M = {}

local s_scratch_buffer_count = 1
local s_line_highlight_matches = {}

function M.mark_scratch(bufnr)
    bo[bufnr].buftype = "nofile"
    bo[bufnr].bufhidden = "hide"
    bo[bufnr].swapfile = false
    bo[bufnr].buflisted = true
    cmd("file scratchpad-" .. s_scratch_buffer_count)

    s_scratch_buffer_count = s_scratch_buffer_count + 1
end

function M.close()
    local current_bufnr = fn.bufnr("%")
    local alternate_bufnr = fn.bufnr("#")

    if fn.buflisted(alternate_bufnr) == 1 then
        cmd "buffer #"
    else
        cmd "bnext"
    end

    if fn.bufnr("%") == current_bufnr then cmd "new" end

    if fn.buflisted(current_bufnr) == 1 then
        cmd("bdelete! " .. current_bufnr)
    end
end

function M.clean_trailing_spaces()
    local save_cursor = fn.getpos(".")
    local old_query = fn.getreg('/')
    cmd [[silent! %s/\s\+$//e]]
    fn.setpos('.', save_cursor)
    fn.setreg('/', old_query)
end

function M.toggle_colorcolumn(col)
    local columns = fn.split(wo.colorcolumn, ",")
    if col == -1 then
        columns = {columns[1]}
    else
        local found = table.index_of(columns, tostring(col))
        if found > -1 then
            table.remove(columns, found)
        else
            table.insert(columns, col)
        end
    end

    wo.colorcolumn = fn.join(columns, ",")
end

function M.open_uri_under_cursor()
    local uri = fn.expand('<cWORD>')
    uri = fn.substitute(uri, '?', '\\\\?', '')
    uri = fn.substitute(uri, ' ', '\\ ', '')
    uri = fn.shellescape(uri, 1)

    if uri ~= '' then
        cmd("silent !open '" .. uri .. "'")
        cmd(":redraw!")
    end
end

function M.highlight_line(winnr, linenr)
    linenr = linenr or fn.line('.')
    winnr = winnr or fn.winnr()
    local match = fn.matchadd('CursorLine', '\\%' .. linenr .. 'l', 10, -1, {window=winnr})
    table.insert(s_line_highlight_matches, {linenr=linenr, match=match})
end

function M.clear_line_highlight(winnr, linenr)
    local clear_all = linenr == -1
    linenr = linenr or fn.line('.')
    winnr = winnr or fn.winnr()

    local found = false
    for index,value in ipairs(s_line_highlight_matches) do
        if value.linenr == linenr or clear_all then
            fn.matchdelete(value.match, winnr)
            s_line_highlight_matches[index] = nil
        end
    end
end

return M

-- vim: foldmethod=marker
