local M = {}
local vim = vim
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd
local utils = require("vimrc.utils")
local options = require("options")

options.register_option({
    name = "completion_timeout",
    default = 150,
    type_info = "number",
    source = "completion",
    buffer_local = true,
})

-- Variables {{{

local s_completion_timout = -1
local s_last_cursor_position = nil
local s_completion_timer = nil
local s_completion_sources = {
    {
        keys = "<c-x><c-o>",
        prediciate = function()
            return vim.bo.omnifunc ~= "" or vim.o.omnifunc ~= ""
        end,
    },
    {
        keys = "<c-x><c-u>",
        prediciate = function()
            return vim.bo.completefunc ~= "" or vim.o.completefunc ~= ""
        end,
    },
    { keys = "<c-x><c-n>" },
    { keys = "<c-n>" },
    {
        keys = "<c-x><c-]>",
        prediciate = function()
            return #fn.tagfiles() > 0
        end,
    },
    { keys = "<c-x><c-v>", filetypes = { "vim" } },
    { keys = "<c-x><c-f>" },
    {
        keys = "<c-x><c-k>",
        prediciate = function()
            return pcall(api.nvim_buf_get_option, ".", "dictionary")
                or pcall(api.nvim_get_option, ".", "dictionary")
        end,
    },
    {
        keys = "<c-x><c-s>",
        prediciate = function()
            return vim.wo.spell
        end,
    },
    { keys = "<c-x><c-l>" },
}
local s_completion_index = nil
local s_is_completion_dispatched = false
local s_buffer_completion_sources_cache = {}

-- }}}

-- Local Functions {{{

local function get_completion_sources(bufnr)
    if s_buffer_completion_sources_cache[bufnr] ~= nil then
        return s_buffer_completion_sources_cache[bufnr]
    end

    s_buffer_completion_sources_cache[bufnr] = s_completion_sources
    return s_buffer_completion_sources_cache[bufnr]
end

local function timer_handler()
    if s_completion_index == -1 then
        return
    end

    if api.nvim_get_mode().mode == "n" then
        s_completion_index = -1
        return
    end

    local bufnr = vim.fn.bufnr()
    local filetype = api.nvim_buf_get_option(bufnr, "filetype")
    local completion_sources = get_completion_sources(bufnr)

    if vim.fn.pumvisible() == 0 then
        if s_completion_index == #completion_sources + 1 then
            s_is_completion_dispatched = false
        else
            local source = completion_sources[s_completion_index]
            if
                (source.prediciate ~= nil and source.prediciate() == false)
                or source.filetype ~= nil and source.filetype ~= filetype
            then
                s_completion_index = s_completion_index + 1
                timer_handler()
                return
            end

            local mode_keys = api.nvim_replace_termcodes(source.keys, true, false, true)
            api.nvim_feedkeys(
                api.nvim_replace_termcodes("<c-g><c-g>", true, false, true),
                "n",
                true
            )
            api.nvim_feedkeys(mode_keys, "n", true)
            s_is_completion_dispatched = true
            s_completion_index = s_completion_index + 1
        end
    end

    if s_completion_timer ~= nil then
        s_completion_timer:stop()
        s_completion_timer:close()
        s_completion_timer = nil
    end
end

-- Completion Functions {{{

function M.complete_mnemonic(lines, base)
    local words = {}

    local function split_token(str, sep, sep2)
        local res = {}
        local mn_chars = {}

        local ww = {}
        string.gsub(str, sep, function(w)
            table.insert(res, w)
        end)
        for _, v in ipairs(res) do
            string.gsub(v, sep2, function(w)
                table.insert(ww, w)
            end)
        end

        if #res > 0 then
            for _, v in ipairs(ww) do
                table.insert(mn_chars, string.sub(v, 1, 1))
            end
        end

        if #res == 0 then
            return { mn = {}, word = str }
        end
        return { mn = mn_chars, word = res[1] }
    end

    local function get_mnemonics(token, sep)
        local result = split_token(token, sep, "[A-Z]+")
        local characters = result.mn
        local words = {}
        if #characters > 0 then
            if characters[1] ~= string.sub(result.word, 1, 1) then
                mnemonic = string.lower(
                    string.sub(result.word, 1, 1) .. string.join(characters, "")
                )
            else
                mnemonic = string.lower(string.join(characters, ""))
            end

            if mnemonic == base then
                table.insert(
                    words,
                    { label = result.word, insertText = result.word, detail = "mnemonic" }
                )
            end
        end

        return words
    end

    for _, line in ipairs(lines) do
        for token in string.gmatch(line, "[^%s. ]+") do
            local result = split_token(token, ".*_[a-zA-Z]+", "[^_]+")
            local characters = result.mn
            if #characters > 0 then
                mnemonic = string.join(characters, "")
                if mnemonic == base then
                    table.insert(
                        words,
                        { label = result.word, insertText = result.word, detail = "mnemonic" }
                    )
                end
            end

            table.extend(words, get_mnemonics(token, "[a-zA-Z]+"))
        end
    end

    return words
end

local function complete_custom(findstart, base)
    if base == "" then
        local pos = api.nvim_win_get_cursor(0)
        local line = api.nvim_get_current_line()
        local line_to_cursor = line:sub(1, pos[2])
        return vim.fn.match(line_to_cursor, "\\k*$")
    end

    local completions = {}
    local lines = api.nvim_buf_get_lines(0, 0, -1, false)

    table.extend(completions, M.complete_mnemonic(lines, base))

    return completions
end

-- }}}

_G.trigger_custom_completion = function(find_start, base)
    return complete_custom(find_start, base)
end

-- }}}

-- Public API {{{

-- Event Handlers {{{

function M.on_complete_done_pre()
    if api.nvim_get_mode().mode == "n" then
        s_completion_index = -1
        return
    end

    if s_completion_index == -1 or vim.fn.pumvisible() == 1 then
        return
    end

    local info = vim.fn.complete_info()
    if #info.items > 0 then
        api.nvim_feedkeys(api.nvim_replace_termcodes("<c-y>", true, false, true), "n", true)
        s_completion_index = -1
        return
    end

    if s_completion_timer ~= nil then
        return
    end

    s_completion_timer = vim.loop.new_timer()
    local timeout = options.get_option_value("completion_timeout", api.nvim_get_current_buf())

    s_completion_timer:start(timeout, 0, vim.schedule_wrap(timer_handler))
end

function M.on_complete_done(bufnr)
    if s_is_completion_dispatched == true then
        return
    end
    if s_last_cursor_position == nil then
        s_completion_index = -1
        return
    end

    local completion_sources = get_completion_sources(bufnr)
    local cursorPosition = api.nvim_win_get_cursor(0)
    if
        cursorPosition[1] == s_last_cursor_position[1]
        and cursorPosition[2] == s_last_cursor_position[2]
        and s_completion_index == #completion_sources + 1
    then
        api.nvim_feedkeys(api.nvim_replace_termcodes("<c-y>", true, false, true), "n", true)
        s_completion_index = -1
    end
end

-- }}}

function M.trigger_completion()
    s_completion_index = 1

    s_last_cursor_position = api.nvim_win_get_cursor(0)
    timer_handler()
    s_completion_timer = vim.loop.new_timer()
    -- Run this first because otherwise the completion is not triggered when
    -- it is done the first time.
    s_completion_timer:start(
        10,
        0,
        vim.schedule_wrap(function()
            s_completion_timer:stop()
            s_completion_timer:close()
            s_completion_timer = nil

            M.on_complete_done_pre()
        end)
    )
end

function M.setup_completion(bufnr)
    if vim.fn.exists("b:vimrc_is_completion_configured") == 0 then
        api.nvim_buf_set_var(bufnr, "vimrc_is_completion_configured", false)
    elseif api.nvim_buf_get_var(bufnr, "vimrc_is_completion_configured") == 1 then
        return
    end

    vim.bo[bufnr].completefunc = "v:lua.trigger_custom_completion"

    cmd("augroup vimrc_completion_buf_" .. bufnr)
    cmd([[au!]])
    cmd(
        "autocmd CompleteDonePre <buffer="
            .. bufnr
            .. ">"
            .. " lua require'vimrc.completion'.on_complete_done_pre()"
    )

    cmd(
        "autocmd CompleteDone <buffer="
            .. bufnr
            .. ">"
            .. " lua require'vimrc.completion'.on_complete_done("
            .. bufnr
            .. ")"
    )
    cmd([[augroup END]])

    api.nvim_buf_set_var(bufnr, "vimrc_is_completion_configured", true)
end

function M.add_source(source, bufnr)
    assert(source.keys ~= nil, "keys are required.")

    table.insert(s_completion_sources, source)

    if s_buffer_completion_sources_cache[bufnr] ~= nil then
        s_buffer_completion_sources_cache[bufnr] = nil
    end
end

-- }}}

return M

-- vim: foldmethod=marker
