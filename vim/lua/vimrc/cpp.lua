local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local g = vim.g
local b = vim.b
local bo = vim.bo
local utils = require "vimrc.utils"
local log = require "vimrc.log"
local M = {}

function M.swap_source_header()
    local suffixes = string.split(bo.suffixesadd, ",")

    local filename = fn.expand('%:t')
    for index, suffix in ipairs(suffixes) do
        local tmp = string.gsub(filename, suffix .. "$", "")
        if filename ~= tmp then
            filename = tmp
            table.remove(suffixes, index)
        end
    end

    cmd("execute 'setlocal path+=' . expand('%:h')")

    local found = false
    for _, suffix in ipairs(suffixes) do
        local found_file = fn.findfile(filename .. suffix)
        if found_file ~= "" then
            found = true
            cmd("edit " .. found_file)
            break
        end
    end

    cmd("execute 'setlocal path-=' . expand('%:h')")

    if found == false then
        log.error("cpp", "Cannot swap source/header for " .. fn.expand('%:t'))
    end
end

return M
