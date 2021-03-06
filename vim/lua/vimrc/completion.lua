local M = {}
local vim = vim
local fn = vim.fn
local utils = require 'vimrc.utils'

-- Variables {{{

local s_last_cursor_position = nil
local s_completion_timer = nil
local s_completion_sources = {
    {
        keys = "<c-x><c-o>",
        prediciate = function()
            return vim.bo.omnifunc ~= "" or vim.o.omnifunc ~= ""
        end
    }, {
        keys = "<c-x><c-u>",
        prediciate = function()
            return vim.bo.completefunc ~= "" or vim.o.completefunc ~= ""
        end
    }, {keys = "<c-x><c-n>"}, {keys = "<c-n>"},
    {keys = "<c-x><c-v>", filetypes = {"vim"}}, {keys = "<c-x><c-f>"}, {
        keys = "<c-x><c-k>",
        prediciate = function()
            return pcall(vim.api.nvim_buf_get_option, '.', "dictionary") or
                       pcall(vim.api.nvim_get_option, '.', "dictionary")
        end
    }, {keys = "<c-x><c-s>", prediciate = function() return vim.wo.spell end}
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
    if s_completion_index == -1 then return end

    if vim.api.nvim_get_mode().mode == "n" then
        s_completion_index = -1
        return
    end

    local bufnr = vim.fn.bufnr()
    local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
    local completion_sources = get_completion_sources(bufnr)

    if vim.fn.pumvisible() == 0 then
        if s_completion_index == #completion_sources + 1 then
            s_is_completion_dispatched = false
        else
            local source = completion_sources[s_completion_index]
            if (source.prediciate ~= nil and source.prediciate() == false) or
                source.filetype ~= nil and source.filetype ~= filetype then
                s_completion_index = s_completion_index + 1
                timer_handler()
                return
            end

            local mode_keys = vim.api.nvim_replace_termcodes(source.keys, true,
                                                             false, true)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<c-g><c-g>",
                                                                 true, false,
                                                                 true), 'n',
                                  true)
            vim.api.nvim_feedkeys(mode_keys, 'n', true)
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

local function complete_fzf(lines, base)
    local input = {}
    for _, line in ipairs(lines) do
        for token in string.gmatch(line, "[%w+]?[.*_[a-zA-Z]+]?") do
            table.insert(input, token)
        end
    end

    local completions = {}
    local output = vim.fn.systemlist("fzf --filter=" .. base, input)
    for _, value in ipairs(output) do
        table.insert(completions, {word = value})
    end

    return completions
end

local function complete_mnemonic(lines, base)
    local words = {}

    local function split_token(str, sep, sep2)
        local res = {}
        local mn_chars = {}

        local ww = {}
        string.gsub(str, sep, function(w) table.insert(res, w) end)
        for _, v in ipairs(res) do
            string.gsub(v, sep2, function(w) table.insert(ww, w) end)
        end

        if #res > 0 then
            for _, v in ipairs(ww) do
                table.insert(mn_chars, string.sub(v, 1, 1))
            end
        end

        if #res == 0 then return {mn = {}, word = str} end
        return {mn = mn_chars, word = res[1]}
    end

    local function get_mnemonics(token, sep)
        local result = split_token(token, sep, "[A-Z]+")
        local characters = result.mn
        local words = {}
        if #characters > 0 then
            if characters[1] ~= string.sub(result.word, 1, 1) then
                mnemonic = string.lower(string.sub(result.word, 1, 1) ..
                                            string.join(characters, ""))
            else
                mnemonic = string.lower(string.join(characters, ""))
            end

            if mnemonic == base then
                table.insert(words, {word = result.word})
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
                    table.insert(words, {word = result.word})
                end
            end

            table.extend(words, get_mnemonics(token, "[a-zA-Z]+"))
        end
    end

    return words
end

-- }}}

-- }}}

-- Public API {{{

-- Event Handlers {{{

function M.on_complete_done_pre()
    if vim.api.nvim_get_mode().mode == "n" then
        s_completion_index = -1
        return
    end

    if s_completion_index == -1 or vim.fn.pumvisible() == 1 then return end

    local info = vim.fn.complete_info()
    if #info.items > 0 then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<c-y>", true,
                                                             false, true), "n",
                              true)
        s_completion_index = -1
        return
    end

    if s_completion_timer ~= nil then return end

    s_completion_timer = vim.loop.new_timer()
    s_completion_timer:start(vim.api.nvim_buf_get_var(bufnr,
                                                      "vimrc_completion_timeout"),
                             0, vim.schedule_wrap(timer_handler))
end

function M.on_complete_done(bufnr)
    if s_is_completion_dispatched == true then return end
    if s_last_cursor_position == nil then
        s_completion_index = -1
        return
    end

    local completion_sources = get_completion_sources(bufnr)
    local cursorPosition = vim.api.nvim_win_get_cursor(0)
    if cursorPosition[1] == s_last_cursor_position[1] and cursorPosition[2] ==
        s_last_cursor_position[2] and s_completion_index == #completion_sources +
        1 then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<c-y>", true,
                                                             false, true), "n",
                              true)
        s_completion_index = -1
    end
end

-- }}}

function M.complete_custom(findstart, base)
    local line = vim.fn.getline('.')
    if base == "" then
        local start = vim.fn.col('.') - 1
        local current_char = string.sub(line, start, start)
        while start > 0 and string.match(current_char, "[%w+]?[.*_[a-zA-Z]+]?") ~=
            nil do
            start = start - 1
            current_char = string.sub(line, start, start)
        end

        return start
    end

    local completions = {}
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    table.extend(completions, complete_mnemonic(lines, base))
    table.extend(completions, complete_fzf(lines, base))

    return completions
end

function M.trigger_completion()
    s_completion_index = 1

    s_last_cursor_position = vim.api.nvim_win_get_cursor(0)
    timer_handler()
    s_completion_timer = vim.loop.new_timer()
    -- Run this first because otherwise the completion is not triggered when
    -- it is done the first time.
    s_completion_timer:start(10, 0, vim.schedule_wrap(
                                 function()
            s_completion_timer:stop()
            s_completion_timer:close()
            s_completion_timer = nil

            M.on_complete_done_pre()
        end))
end

function M.setup_completion(bufnr)
    if vim.fn.exists("b:vimrc_is_completion_configured") == 0 then
        vim.api.nvim_buf_set_var(bufnr, "vimrc_is_completion_configured", false)
    elseif vim.api.nvim_buf_get_var(bufnr, "vimrc_is_completion_configured") ==
        1 then
        return
    end

    if vim.fn.exists("b:vimrc_completion_timeout") == 0 then
        vim.api.nvim_buf_set_var(bufnr, "vimrc_completion_timeout", 250)
    end

    vim.bo[bufnr].completefunc = "completion#trigger_custom"

    vim.api.nvim_command("augroup vimrc_completion_buf_" .. bufnr)
    vim.api.nvim_command("au!")
    vim.api.nvim_command("autocmd CompleteDonePre <buffer=" .. bufnr ..
                             "> lua require'vimrc.completion'.on_complete_done_pre()")
    vim.api.nvim_command("autocmd CompleteDone <buffer=" .. bufnr ..
                             "> lua require'vimrc.completion'.on_complete_done(" ..
                             bufnr .. ")")
    vim.api.nvim_command("augroup END")

    vim.api.nvim_buf_set_var(bufnr, "vimrc_is_completion_configured", true)
end

function M.add_source(source, bufnr)
    assert(source.keys ~= nil)
    table.insert(s_completion_sources, source)

    if s_buffer_completion_sources_cache[bufnr] ~= nil then
        s_buffer_completion_sources_cache[bufnr] = nil
    end
end

-- }}}

return M

-- vim: foldmethod=marker
