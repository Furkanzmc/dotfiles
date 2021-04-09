local vim = vim
local dap = require "dap"
local M = {}

function M.init()
    dap.adapters.cpp = {
        name = "lldb",
        type = 'executable',
        attach = {pidProperty = "pid", pidSelect = "ask"},
        command = vim.g.vimrc_dap_lldb_vscode_path,
        env = {LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES"}
    }
end

return M
