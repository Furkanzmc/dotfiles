local vim = vim
local M = {}

local last_cursor_position = nil
local completion_timer = nil
local completion_sources = {
    "<c-x><c-o>",
    "<c-x><c-n>",
    "<c-x><c-f>",
    "<c-x><c-k>",
    "<c-g><c-g><c-n>"
}
local completion_index = nil
local completion_dispatched = false

function timer_handler()
    if completion_index == -1 then
        return
    end

    if vim.api.nvim_get_mode().mode == "n" then
        completion_index = -1
        return
    end

    if vim.fn.pumvisible() == 0 then
        if completion_index == #completion_sources + 1 then
            completion_dispatched = false
        else
            local mode_keys = completion_sources[completion_index]

            if mode_keys == "<c-x><c-k>" and not pcall(vim.api.nvim_buf_get_option, '.', "dictionary") then
                completion_index = completion_index + 1
                mode_keys = completion_sources[completion_index]
            end

            mode_keys = vim.api.nvim_replace_termcodes(mode_keys, true, false, true)
            vim.api.nvim_feedkeys(mode_keys, 'n', true)
            completion_dispatched = true
            completion_index = completion_index + 1
        end
    end

    if completion_timer ~= nil then
        completion_timer:stop()
        completion_timer:close()
        completion_timer = nil
    end
end

M.on_complete_done_pre = function()
    if vim.api.nvim_get_mode().mode == "n" then
        completion_index = -1
        return
    end

    if completion_index == -1 then
        return
    end

    if vim.fn.pumvisible() == 1 then
        return
    end

    local info = vim.fn.complete_info()
    if #info.items > 0 then
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<c-y>", true, false, true), "n",
            true
            )
        completion_index = -1
        return
    end

    if completion_timer ~= nil then
        return
    end

    completion_timer = vim.loop.new_timer()
    completion_timer:start(100, 0, vim.schedule_wrap(timer_handler))
end

M.on_complete_done = function()
    if completion_dispatched == true then
        return
    end

    local cursorPosition = vim.api.nvim_win_get_cursor(0)
    if cursorPosition[1] == last_cursor_position[1] and cursorPosition[2] == last_cursor_position[2] and completion_index == #completion_sources + 1 then
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<c-y>", true, false, true), "n",
            true
            )
        completion_index = -1
    end
end

M.trigger_completion = function()
    if require'lsp'.is_lsp_running() then
        completion_index = 1
    else
        completion_index = 2
    end

    last_cursor_position = vim.api.nvim_win_get_cursor(0)
    timer_handler()
    completion_timer = vim.loop.new_timer()
    -- Run this first because otherwise the completion is not triggered when
    -- it is done the first time.
    completion_timer:start(10, 0, vim.schedule_wrap(function()
        completion_timer:stop()
        completion_timer:close()
        completion_timer = nil

        M.on_complete_done_pre()
    end))
end


M.setup_completion = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local is_configured = vim.api.nvim_buf_get_var(bufnr, "is_completion_configured")

    if is_configured then
        return
    end

    vim.api.nvim_command(
        "autocmd CompleteDonePre <buffer> lua require'completion'.on_complete_done_pre()")
    vim.api.nvim_command(
        "autocmd CompleteDone <buffer> lua require'completion'.on_complete_done()")

    vim.api.nvim_buf_set_var(bufnr, "is_completion_configured", true)
end

return M
