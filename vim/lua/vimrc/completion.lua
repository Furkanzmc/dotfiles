local vim = vim
local M = {}

local s_last_cursor_position = nil
local s_completion_timer = nil
local s_completion_sources = {
    omni={
        keys="<c-x><c-o>",
        priority=1,
        prediciate=function()
            return vim.bo.omnifunc ~= "" or vim.o.omnifunc ~= ""
        end
    },
    keywords_current={
        keys="<c-x><c-n>",
        priority=2,
    },
    file={
        keys="<c-x><c-f>",
        priority=3,
    },
    dictionary={
        keys="<c-x><c-k>",
        priority=4,
        prediciate=function()
            return pcall(vim.api.nvim_buf_get_option, '.', "dictionary") or pcall(vim.api.nvim_get_option, '.', "dictionary")
        end
    },
    keywords={
        keys="<c-g><c-g><c-n>",
        priority=5,
    },
    spell={
        keys="<c-x><c-s>",
        priority=6,
        prediciate=function()
            return vim.wo.spell
        end
    },
    user={
        keys="<c-x><c-u>",
        priority=7,
        prediciate=function()
            return vim.bo.completefunc ~= "" or vim.o.completefunc ~= ""
        end
    },
}
local s_completion_index = nil
local s_is_completion_dispatched = false
local s_plugin_loaded = false
local s_buffer_completion_sources_cache = {}
local s_buffer_completion_source_names_cache = {}

function get_completion_sources(bufnr)
    if s_buffer_completion_sources_cache[bufnr] ~= nil then
        return s_buffer_completion_sources_cache[bufnr]
    end

    local result = pcall(vim.api.nvim_buf_get_var, bufnr, "vimrc_completion_additional_sources")
    if result == false then
        return s_completion_sources
    end

    local additional_sources = vim.api.nvim_buf_get_var(bufnr, "vimrc_completion_additional_sources")
    local new_list = {}

    for key, value in pairs(s_completion_sources) do
        new_list[key] = value
    end

    for index, value in ipairs(additional_sources) do
        new_list["custom_" .. index] = {keys=value, priority=-1}
    end

    s_buffer_completion_sources_cache[bufnr] = new_list
    return new_list
end

function get_source_names(bufnr)
    if s_buffer_completion_source_names_cache[bufnr] ~= nil then
        return s_buffer_completion_source_names_cache[bufnr]
    end

    local sources = get_completion_sources(bufnr)
    local names = {}

    for key,_ in pairs(sources) do
        table.insert(names, key)
    end

    table.sort(names, function(a, b)
        if sources[a].priority == -1 or sources[a].priority == nil then
            return false
        end

        if sources[b].priority == -1 or sources[b].priority == nil then
            return true
        end

        return sources[a].priority < sources[b].priority
    end)

    s_buffer_completion_source_names_cache[bufnr] = names
    return names
end

function timer_handler()
    if s_completion_index == -1 then
        return
    end

    if vim.api.nvim_get_mode().mode == "n" then
        s_completion_index = -1
        return
    end

    local bufnr = vim.fn.bufnr()
    local completion_sources = get_completion_sources(bufnr)
    local completion_source_names = get_source_names(bufnr)

    if vim.fn.pumvisible() == 0 then
        if s_completion_index == #completion_source_names + 1 then
            s_is_completion_dispatched = false
        else
            local source = completion_sources[completion_source_names[s_completion_index]]
            if source.prediciate ~= nil and source.prediciate() == false then
                s_completion_index = s_completion_index + 1
                timer_handler()
                return
            end

            local mode_keys = vim.api.nvim_replace_termcodes(source.keys, true, false, true)
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

M.on_complete_done_pre = function()
    if vim.api.nvim_get_mode().mode == "n" then
        s_completion_index = -1
        return
    end

    if s_completion_index == -1 or vim.fn.pumvisible() == 1 then
        return
    end

    local info = vim.fn.complete_info()
    if #info.items > 0 then
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<c-y>", true, false, true),
            "n", true)
        s_completion_index = -1
        return
    end

    if s_completion_timer ~= nil then
        return
    end

    s_completion_timer = vim.loop.new_timer()
    s_completion_timer:start(
        vim.api.nvim_buf_get_var(bufnr, "vimrc_completion_timeout"), 0,
        vim.schedule_wrap(timer_handler))
end

M.on_complete_done = function(bufnr)
    if s_is_completion_dispatched == true then
        return
    end

    local completion_sources = get_completion_sources(bufnr)
    local cursorPosition = vim.api.nvim_win_get_cursor(0)
    if cursorPosition[1] == s_last_cursor_position[1] and cursorPosition[2] == s_last_cursor_position[2] and s_completion_index == #completion_sources + 1 then
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<c-y>", true, false, true), "n",
            true
            )
        s_completion_index = -1
    end
end

M.trigger_completion = function()
    if require'vimrc.lsp'.is_lsp_running() then
        s_completion_index = 1
    else
        s_completion_index = 2
    end

    s_last_cursor_position = vim.api.nvim_win_get_cursor(0)
    timer_handler()
    s_completion_timer = vim.loop.new_timer()
    -- Run this first because otherwise the completion is not triggered when
    -- it is done the first time.
    s_completion_timer:start(10, 0, vim.schedule_wrap(function()
        s_completion_timer:stop()
        s_completion_timer:close()
        s_completion_timer = nil

        M.on_complete_done_pre()
    end))
end


M.setup_completion = function(bufnr)
    if vim.fn.exists("b:vimrc_is_completion_configured") == 0 then
        vim.api.nvim_buf_set_var(bufnr, "vimrc_is_completion_configured", false)
    elseif vim.api.nvim_buf_get_var(bufnr, "vimrc_is_completion_configured") == 1 then
        return
    end

    if vim.fn.exists("b:vimrc_completion_timeout") == 0 then
        vim.api.nvim_buf_set_var(bufnr, "vimrc_completion_timeout", 250)
    end

    vim.api.nvim_command("augroup vimrc_completion_buf_" .. bufnr)
    vim.api.nvim_command("au!")
    vim.api.nvim_command(
        "autocmd CompleteDonePre <buffer=" .. bufnr .. "> lua require'vimrc.completion'.on_complete_done_pre()")
    vim.api.nvim_command(
        "autocmd CompleteDone <buffer=" .. bufnr .. "> lua require'vimrc.completion'.on_complete_done(" .. bufnr .. ")")
    vim.api.nvim_command("augroup END")

    vim.api.nvim_buf_set_var(bufnr, "vimrc_is_completion_configured", true)
end

return M
