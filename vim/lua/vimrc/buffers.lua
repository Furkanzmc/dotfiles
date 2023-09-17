local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local g = vim.g
local b = vim.b
local bo = vim.bo
local wo = vim.wo
local opt_local = vim.opt_local
local opt = vim.opt
local api = vim.api
local options = require("options")
local typing = require("vimrc.typing")
local s_buffer_minimal_cache = {}
local M = {}

local s_scratch_buffer_count = 1

-- Buffer related code from https://stackoverflow.com/a/4867969
local function get_buflist()
    return fn.filter(fn.range(1, fn.bufnr("$")), "buflisted(v:val)")
end

local function set_minimal_mode(is_minimal, bufnr)
    if is_minimal then
        assert(s_buffer_minimal_cache[bufnr] == nil)
        s_buffer_minimal_cache[bufnr] = {
            relativenumber = opt_local.relativenumber,
            number = opt_local.number,
            showcmd = opt_local.showcmd,
            showmode = opt_local.showmode,
            ruler = opt_local.ruler,
            colorcolumn = opt_local.colorcolumn,
            cursorline = opt_local.cursorline,
            laststatus = opt_local.laststatus,
            signcolumn = opt_local.signcolumn,
            tabline = opt_local.tabline,
        }

        opt_local.relativenumber = false
        opt_local.number = false
        opt_local.showcmd = false
        opt_local.showmode = false
        opt_local.ruler = false
        opt_local.colorcolumn = ""
        opt_local.cursorline = false
        opt_local.laststatus = 0
        opt_local.signcolumn = "no"
        opt_local.tabline = "%#Normal#%T"
    else
        local cached_options = s_buffer_minimal_cache[bufnr]
        assert(cached_options ~= nil, "Options cache is not found.")
        opt_local.relativenumber = cached_options.relativenumber
        opt_local.number = cached_options.number
        opt_local.showcmd = cached_options.showcmd
        opt_local.showmode = cached_options.showmode
        opt_local.ruler = cached_options.ruler
        opt_local.colorcolumn = cached_options.colorcolumn
        opt_local.cursorline = cached_options.cursorline
        opt_local.laststatus = cached_options.laststatus
        opt_local.tabline = cached_options.tabline
        s_buffer_minimal_cache[bufnr] = nil
    end
end

local function mark_scratch(bufnr)
    if options.get_option_value("scratchpad", bufnr) == true then
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
        cmd("buffer #")
    else
        cmd("bnext")
    end

    if fn.bufnr("%") == current_bufnr then
        cmd("new")
    end

    if fn.buflisted(current_bufnr) == 1 then
        cmd("bdelete! " .. current_bufnr)
    end
end

function M.clean_trailing_spaces(bufnr)
    if options.get_option_value("clean_trailing_whitespace", bufnr) == false then
        return
    end

    local save_cursor = fn.getpos(".")
    local old_query = fn.getreg("/")
    local threshold = options.get_option_value("clean_trailing_whitespace_limit", bufnr)
    if threshold > 0 then
        cmd([[redir => g:trailing_space_count]])
        cmd([[silent %s/\s\+$//egn]])
        cmd([[redir END]])
        local result = fn.matchstr(g.trailing_space_count, "\\d\\+")
        cmd([[unlet g:trailing_space_count]])

        if result ~= "" then
            result = tonumber(result)
        else
            return
        end

        if result <= threshold then
            cmd([[silent! %s/\s\+$//e]])
        else
            local choice = fn.input(
                "[buffers] Found "
                    .. result
                    .. " trailing white spaces. Do you want to clean? [y/n/p] "
            )
            if choice == "p" then
                cmd([[%s/\s\+$//ec]])
            elseif typing.toboolean(choice) == true then
                cmd([[%s/\s\+$//e]])
            end
        end
    else
        cmd([[%s/\s\+$//e]])
    end

    fn.setpos(".", save_cursor)
    fn.setreg("/", old_query)
end

function M.toggle_colorcolumn(col)
    local columns = fn.split(wo.colorcolumn, ",")
    if col == -1 then
        columns = { columns[1] }
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

function M.init()
    options.register_callback("scratchpad", function()
        mark_scratch(vim.api.nvim_get_current_buf())
    end)
    options.register_callback("highlight_trailing_whitespace", function()
        local bufnr = vim.api.nvim_get_current_buf()
        if options.get_option_value("highlight_trailing_whitespace", bufnr) then
            M.setup_white_space_highlight(bufnr)
        else
            fn.clearmatches()
            cmd("augroup vimrc_trailing_white_space_highlight_buffer_" .. bufnr)
            cmd([[autocmd! * <buffer>]])
            cmd([[augroup END]])
        end
    end)

    options.register_callback("markdownfenced", function()
        local langs = options.get_option_value("markdownfenced", vim.api.nvim_get_current_buf())

        if g.markdown_fenced_languages == nil then
            g.markdown_fenced_languages = {}
        end

        g.markdown_fenced_languages = table.uniq(table.extend(g.markdown_fenced_languages, langs))
    end)

    options.register_callback("indentsize", function()
        local isize = options.get_option_value("indentsize", vim.api.nvim_get_current_buf())
        cmd(string.format("setlocal tabstop=%s softtabstop=%s shiftwidth=%s", isize, isize, isize))
    end)

    options.register_callback("minimal_buffer", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local is_minimal = options.get_option_value("minimal_buffer", bufnr)
        set_minimal_mode(is_minimal, bufnr)
    end)
end

function M.setup_white_space_highlight(bufnr)
    if b.vimrc_trailing_white_space_highlight_enabled then
        return
    end

    if options.get_option_value("highlight_trailing_whitespace", bufnr) == false then
        return
    end

    cmd([[highlight link TrailingWhiteSpace Error]])

    cmd("augroup vimrc_trailing_white_space_highlight_buffer_" .. bufnr)
    cmd([[autocmd! * <buffer>]])
    cmd([[autocmd BufReadPost <buffer> match TrailingWhiteSpace /\s\+$/]])
    cmd([[autocmd InsertEnter <buffer> match TrailingWhiteSpace /\s\+\%#\@<!$/]])
    cmd([[autocmd InsertLeave <buffer> match TrailingWhiteSpace /\s\+$/]])
    cmd([[augroup END]])

    b.vimrc_trailing_white_space_highlight_enabled = true
end

function M.get_modified_buf_count(tabnr, exclude)
    if exclude == nil then
        exclude = {}
    end

    local modified_buf_count = 0
    if tabnr == -1 then
        local modified_list = fn.filter(fn.getbufinfo(), "v:val.changed == 1")
        modified_list = table.filter(modified_list, function(buf_info)
            if vim.bo[buf_info.bufnr].buftype == "prompt" then
                return false
            end

            return table.index_of(modified_list, buf_info.bufnr) == -1
        end)

        modified_buf_count = #modified_list
    else
        local buflist = table.uniq(fn.tabpagebuflist(tabnr))
        local modified_list = table.filter(buflist, function(bufnr)
            if vim.bo[bufnr].buftype == "prompt" then
                return false
            end
            if fn.getbufvar(bufnr, "&mod") == 1 then
                return true
            end
            return false
        end)

        modified_buf_count = #modified_list
    end

    return modified_buf_count
end

-- Code taken from here: https://stackoverflow.com/a/6271254
function M.get_last_selection(bufnr)
    local line_start, column_start = (function()
        local pos = fn.getpos("'<")
        return pos[2], pos[3]
    end)()
    local line_end, column_end = (function()
        local pos = fn.getpos("'>")
        return pos[2], pos[3]
    end)()

    local lines = api.nvim_buf_get_lines(bufnr, line_start - 1, line_end, true)
    if #lines == 0 then
        return lines
    end

    local last_index = #lines
    local selection = opt.selection:get()
    if selection == "inclusive" then
        lines[last_index] = string.sub(lines[last_index], 0, column_end - 1)
    else
        lines[last_index] = string.sub(lines[last_index], 0, column_end - 2)
    end

    lines[1] = string.sub(lines[1], column_start - 1, #lines[1])

    return lines
end

function M.get_buffer_names()
    return fn.map(get_buflist(), "bufname(v:val)")
end

return M
