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

function M.highlight_line(winnr, start_line, end_line)
    start_line = start_line or fn.line('.')
    end_line = end_line or fn.line('.')
    winnr = winnr or fn.winnr()
    local range = fn.range(start_line, end_line)
    for _, linenr in ipairs(range) do
        local match = fn.matchadd('CursorLine', '\\%' .. linenr .. 'l', 10, -1,
                                  {window = winnr})
        table.insert(s_line_highlight_matches, {linenr = linenr, match = match})
    end

    table.sort(s_line_highlight_matches,
               function(a, b) return a.linenr > b.linenr end)
end

function M.clear_line_highlight(winnr, start_line, end_line, clear_all)
    start_line = start_line or fn.line('.')
    end_line = end_line or fn.line('.')
    winnr = winnr or fn.winnr()

    local range = fn.range(start_line, end_line)
    for index, value in ipairs(s_line_highlight_matches) do
        if table.index_of(range, value.linenr) > -1 or clear_all then
            fn.matchdelete(value.match, winnr)
            s_line_highlight_matches[index] = nil
        end
    end

    table.sort(s_line_highlight_matches,
               function(a, b) return a.linenr > b.linenr end)
end

function M.jump_to_next_line_highlight(winnr, linenr)
    linenr = linenr or fn.line('.')
    local target_linenr = linenr + 1
    winnr = winnr or fn.winnr()

    local range = fn.range(start_line, end_line)
    for _, value in ipairs(s_line_highlight_matches) do
        if value.linenr >= target_linenr then
            cmd("normal " .. value.linenr .. "G")
        end
    end
end

return M

-- vim: foldmethod=marker
