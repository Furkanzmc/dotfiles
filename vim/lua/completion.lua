local vim = vim
local M = {}

local s_last_cursor_position = nil
local s_completion_timer = nil
local s_completion_sources = {
    "<c-x><c-o>",
    "<c-x><c-n>",
    "<c-x><c-f>",
    "<c-x><c-k>",
    "<c-g><c-g><c-n>"
}
local s_completion_index = nil
local s_is_completion_dispatched = false

function timer_handler()
    if s_completion_index == -1 then
        return
    end

    if vim.api.nvim_get_mode().mode == "n" then
        s_completion_index = -1
        return
    end

    if vim.fn.pumvisible() == 0 then
        if s_completion_index == #s_completion_sources + 1 then
            s_is_completion_dispatched = false
        else
            local mode_keys = s_completion_sources[s_completion_index]

            if mode_keys == "<c-x><c-k>" and not pcall(vim.api.nvim_buf_get_option, '.', "dictionary") then
                s_completion_index = s_completion_index + 1
                mode_keys = s_completion_sources[s_completion_index]
            end

            mode_keys = vim.api.nvim_replace_termcodes(mode_keys, true, false, true)
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
    s_completion_timer:start(100, 0, vim.schedule_wrap(timer_handler))
end

M.on_complete_done = function()
    if s_is_completion_dispatched == true then
        return
    end

    local cursorPosition = vim.api.nvim_win_get_cursor(0)
    if cursorPosition[1] == s_last_cursor_position[1] and cursorPosition[2] == s_last_cursor_position[2] and s_completion_index == #s_completion_sources + 1 then
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<c-y>", true, false, true), "n",
            true
            )
        s_completion_index = -1
    end
end

M.trigger_completion = function()
    if require'lsp'.is_lsp_running() then
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


M.setup_completion = function()
    local bufnr = vim.api.nvim_get_current_buf()

    if vim.fn.exists("b:is_completion_configured") == 0 then
        vim.api.nvim_buf_set_var(bufnr, "is_completion_configured", false)
    elseif vim.api.nvim_buf_get_var(bufnr, "is_completion_configured") == 1 then
        return
    end

    vim.api.nvim_command("augroup vimrc_completion_buf_" .. bufnr)
    vim.api.nvim_command("au!")
    vim.api.nvim_command(
        "autocmd CompleteDonePre <buffer=" .. bufnr .. "> lua require'completion'.on_complete_done_pre()")
    vim.api.nvim_command(
        "autocmd CompleteDone <buffer=" .. bufnr .. "> lua require'completion'.on_complete_done()")
    vim.api.nvim_command("augroup END")

    vim.api.nvim_buf_set_var(bufnr, "is_completion_configured", true)
end

return M
