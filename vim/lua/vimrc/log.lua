local vim = vim
local cmd = vim.cmd
local M = {}

function M.error(modl, message)
    cmd [[echohl ErrorMsg]]
    cmd('echo "[' .. modl .. ']: ' .. message .. '"')
    cmd [[echohl Normal]]
end

return M

-- vim: foldmethod=marker
