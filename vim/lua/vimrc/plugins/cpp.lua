local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local g = vim.g
local b = vim.b
local bo = vim.bo
local M = {}

function M.swap_source_header()
    local extension = fn.expand('%:p:e')

    cmd [[setlocal path+=expand('%:h')]]

    local filename = ""
    if extension == 'cpp' then
        filename = fn.expand('%:t:r') .. '.h'
    elseif extension == 'h' then
        filename = fn.expand('%:t:r') .. '.cpp'
    end

    if pcall(cmd, "execute 'find " .. filename .. "'") == false then
        cmd [[echohl ErrorMsg]]
        cmd(echo "[cpp]: Cannot file " .. filename)
        cmd [[echohl Normal]]
    end

    cmd [[setlocal path-=expand('%:h')]]
end

return M
