local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local g = vim.g
local b = vim.b
local bo = vim.bo
local wo = vim.wo
local options = require "vimrc.options"
local typing = require "vimrc.typing"
local M = {}

local s_scratch_buffer_count = 1

local function mark_scratch(bufnr)
    if options.get_option("scratchpad", bufnr) == true then
        bo[bufnr].buftype = "nofile"
        bo[bufnr].bufhidden = "hide"
        bo[bufnr].swapfile = false
        bo[bufnr].buflisted = true
        cmd("file scratchpad-" .. s_scratch_buffer_count)

        s_scratch_buffer_count = s_scratch_buffer_count + 1
    else
        bo[bufnr].buftype = ""
        bo[bufnr].bufhidden = ""
        bo[bufnr].swapfile = false
        bo[bufnr].buflisted = true

        s_scratch_buffer_count = s_scratch_buffer_count + 1
    end
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
    if options.get_option("clstrailingwhitespace", fn.bufnr()) == false then
        return
    end

    local save_cursor = fn.getpos(".")
    local old_query = fn.getreg('/')
    local threshold = options.get_option("clstrailingspacelimit", fn.bufnr())
    if threshold > 0 then
        cmd [[redir => g:trailing_space_count]]
        cmd [[silent %s/\s\+$//egn]]
        cmd [[redir END]]
        local result = fn.matchstr(g.trailing_space_count, '\\d\\+')
        cmd [[unlet g:trailing_space_count]]

        if result ~= "" then
            result = tonumber(result)
        else
            return
        end

        if result <= threshold then
            cmd [[silent! %s/\s\+$//e]]
        else
            local choice = fn.inputdialog(
                               "[buffers] Found " .. result ..
                                   " trailing white spaces. Do you want to clean? [y/n/p] ")
            if choice == "p" then
                cmd [[%s/\s\+$//ec]]
            elseif typing.toboolean(choice) == true then
                cmd [[%s/\s\+$//e]]
            end
        end
    else
        cmd [[%s/\s\+$//e]]
    end

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

function M.init()
    options.register_callback("scratchpad", function()
        mark_scratch(vim.api.nvim_get_current_buf())
    end)
    options.register_callback("trailingwhitespacehighlight", function()
        local bufnr = vim.api.nvim_get_current_buf()
        if options.get_option("trailingwhitespacehighlight") then
            M.setup_white_space_highlight(bufnr)
        else
            fn.clearmatches()
            cmd("augroup trailing_white_space_highlight_buffer_" .. bufnr)
            cmd [[autocmd! * <buffer>]]
            cmd [[augroup END]]
        end
    end)

    options.register_callback("markdownfenced", function()
        local langs = options.get_option("markdownfenced",
                                         vim.api.nvim_get_current_buf())
        if g.markdown_fenced_languages == nil then
            g.markdown_fenced_languages = {}
        end

        g.markdown_fenced_languages = table.uniq(
                                          table.extend(
                                              g.markdown_fenced_languages, langs))
    end)
end

function M.setup_white_space_highlight(bufnr)
    if b.vimrc_trailing_white_space_highlight_enabled then return end

    if options.get_option("trailingwhitespacehighlight", bufnr) == false then
        return
    end

    cmd [[highlight link TrailingWhiteSpace Error]]

    cmd("augroup trailing_white_space_highlight_buffer_" .. bufnr)
    cmd [[autocmd! * <buffer>]]
    cmd [[autocmd BufReadPost <buffer> match TrailingWhiteSpace /\s\+$/]]
    cmd [[autocmd InsertEnter <buffer> match TrailingWhiteSpace /\s\+\%#\@<!$/]]
    cmd [[autocmd InsertLeave <buffer> match TrailingWhiteSpace /\s\+$/]]
    cmd [[augroup END]]

    b.vimrc_trailing_white_space_highlight_enabled = true
end

function M.get_modified_buf_count(tabnr, exclude)
    if exclude == nil then exclude = {} end

    local modified_buf_count = 0
    if tabnr == -1 then
        local modified_list = fn.filter(fn.getbufinfo(), 'v:val.changed == 1')
        modified_list = table.filter(modified_list, function(buf_info)
            return table.index_of(modified_list, buf_info.bufnr) == -1
        end)

        modified_buf_count = #modified_list
    else
        local buflist = table.uniq(fn.tabpagebuflist(tabnr))
        local modified_list = table.filter(buflist, function(bufnr)
            if fn.getbufvar(bufnr, "&mod") == 1 then return true end
            return false
        end)

        modified_buf_count = #modified_list
    end

    return modified_buf_count
end

return M
