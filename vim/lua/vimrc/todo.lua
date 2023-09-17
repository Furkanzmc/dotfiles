local vim = vim
local fn = vim.fn
local g = vim.g
local b = vim.b
local cmd = vim.cmd
local options = require("options")
local s_initialized = false
local s_syntax_enabled = {}

local M = {}

function M.enable_highlight()
    if vim.o.loadplugins == false or g.todo_fenced_languages == nil then
        return
    end

    for _, lang in ipairs(g.todo_fenced_languages) do
        if table.index_of(s_syntax_enabled, lang) >= 1 then
            goto continue
        end

        fn["SyntaxRange#Include"]("```" .. lang, "```", lang, "NonText")
        table.insert(s_syntax_enabled, lang)

        ::continue::
    end

    b.todo_fenced_languages_applied = true
end

function M.init()
    assert(s_initialized == false, "Todo plugin is initialized already.")
    s_initialized = true

    cmd([[packadd SyntaxInclude]])

    if vim.o.loadplugins == true then
        local set_langs = function()
            local langs = options.get_option_value("todofenced", vim.api.nvim_get_current_buf())
            if langs == nil or langs == {} then
                return
            end

            if g.todo_fenced_languages == nil then
                g.todo_fenced_languages = {}
            end

            g.todo_fenced_languages = table.uniq(table.extend(g.todo_fenced_languages, langs))
            M.enable_highlight()
        end

        options.register_callback("todofenced", set_langs)
        set_langs()
    end
end

return M
