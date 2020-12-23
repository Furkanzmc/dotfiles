local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local g = vim.g
local b = vim.b
local bo = vim.bo
local M = {}

local s_scratch_buffer_count = 1

function M.mark_scratch(bufnr)
    bo[bufnr].buftype = "nofile"
    bo[bufnr].bufhidden = "hide"
    bo[bufnr].swapfile = false
    bo[bufnr].buflisted = true
    cmd("file scratchpad-" .. s_scratch_buffer_count)

    s_scratch_buffer_count = s_scratch_buffer_count + 1
end

return M
