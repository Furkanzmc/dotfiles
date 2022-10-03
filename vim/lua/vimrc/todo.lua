local vim = vim
local fn = vim.fn
local g = vim.g
local b = vim.b
local cmd = vim.cmd
local utils = require("vimrc.utils")
local options = require("options")
local s_initialized = false
local M = {}

function M.enable_highlight()
    if
        vim.o.loadplugins == false
        or b.todo_fenced_languages_applied ~= nil
        or g.todo_fenced_languages == nil
    then
        return
    end

    for _, lang in ipairs(g.todo_fenced_languages) do
        fn["SyntaxRange#Include"]("```" .. lang, "```", lang, "NonText")
    end

    b.todo_fenced_languages_applied = true
end

function M.init()
    assert(s_initialized == false, "Todo plugin is initialized already.")
    s_initialized = true

    cmd([[packadd SyntaxInclude]])

    if vim.o.loadplugins == true then
        options.register_callback("todofenced", function()
            local langs = options.get_option_value("todofenced", vim.api.nvim_get_current_buf())
            if g.todo_fenced_languages == nil then
                g.todo_fenced_languages = {}
            end

            g.todo_fenced_languages = table.uniq(table.extend(g.todo_fenced_languages, langs))
            M.enable_highlight()
        end)
    end
end

return M
