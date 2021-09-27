local vim = vim
local fn = vim.fn
local g = vim.g
local b = vim.b
local cmd = vim.cmd
local utils = require "vimrc.utils"
local options = require "options"
local M = {}

function M.enable_highlight()
    if vim.o.loadplugins == false or b.todo_fenced_languages_applied ~= nil or
        g.todo_fenced_languages == nil then return end

    for _, lang in ipairs(g.todo_fenced_languages) do
        fn["SyntaxRange#Include"]('```' .. lang, '```', lang, 'NonText')
    end

    b.todo_fenced_languages_applied = true
end

function M.init()
    cmd [[packadd SyntaxInclude]]
    options.register_callback("todofenced", function()
        local langs = options.get_option("todofenced",
                                         vim.api.nvim_get_current_buf())
        if g.todo_fenced_languages == nil then
            g.todo_fenced_languages = {}
        end

        g.todo_fenced_languages = table.uniq(
                                      table.extend(g.todo_fenced_languages,
                                                   langs))
        M.enable_highlight()
    end)

    cmd [[augroup vimrc_plugin_todo_init]]
    cmd [[au!]]
    cmd [[augroup END]]
end

return M
