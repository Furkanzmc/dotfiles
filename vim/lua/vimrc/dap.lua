local vim = vim
local cmd = vim.cmd
local fn = vim.fn
local map = require("vimrc").map
local M = {}

local function setup_keymaps()
    map("n", "<leader>dc", ":lua require'dap'.continue()<CR>", { silent = true, noremap = true })
    map("n", "<leader>dt", ":lua require'dap'.stop()<CR>", { silent = true, noremap = true })
    map("n", "<leader>ds", ":lua require'dap'.step_into()<CR>", { silent = true, noremap = true })

    map("n", "<leader>dk", ":lua require('dapui').eval()<CR>", { silent = true, noremap = true })
    map("v", "<leader>dk", ":lua require('dapui').eval()<CR>", { silent = true, noremap = true })
    map("n", "<leader>do", ":lua require'dap'.step_out()<CR>", { silent = true, noremap = true })

    map("n", "<leader>dn", ":lua require'dap'.step_over()<CR>", { silent = true, noremap = true })
    map("n", "<leader>du", ":lua require'dap'.up()<CR>", { silent = true, noremap = true })
    map("n", "<leader>dd", ":lua require'dap'.down()<CR>", { silent = true, noremap = true })

    map(
        "n",
        "<leader>db",
        ":lua require'dap'.toggle_breakpoint()<CR>",
        { silent = true, noremap = true }
    )
    map(
        "n",
        "<leader>dbc",
        ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
        { silent = true, noremap = true }
    )
    map(
        "n",
        "<leader>dbl",
        ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
        { silent = true, noremap = true }
    )

    map("n", "<leader>dui", ":lua require'dapui'.toggle()<CR>", { silent = true, noremap = true })
    map("n", "<leader>dr", ":lua lua require'dap'.run_to_cursor()<CR>", { silent = true, noremap = true })
    map(
        "n",
        "<leader>dl",
        ":lua require'dap'.list_breakpoints(true)<CR>",
        { silent = true, noremap = true }
    )
    map(
        "n",
        "<leader>dp",
        ":lua require'dap.ui.variables'.scopes()<CR>",
        { silent = true, noremap = true }
    )
end

local function setup_commands()
    cmd([[command! DapUIOpen :lua require'dapui'.open()]])
    cmd([[command! DapUIClose :lua require'dapui'.close()]])
end

function M.init()
    assert(fn.exists(":DapUIOpen") == 0, "nvim-dap is already initialized.")
    if fn.filereadable(vim.g.vimrc_dap_lldb_vscode_path) == 0 then
        cmd([[echohl ErrorMsg]])
        cmd([[echo 'g:vimrc_dap_lldb_vscode_path is not set.']])
        cmd([[echohl Normal]])
        return
    end

    cmd([[packadd nvim-dap]])
    cmd([[packadd nvim-dap-ui]])

    require("dapui").setup()
    setup_keymaps()
    setup_commands()

    require("dap").adapters.cpp = {
        name = "lldb",
        type = "executable",
        attach = { pidProperty = "pid", pidSelect = "ask" },
        command = vim.g.vimrc_dap_lldb_vscode_path,
        env = { LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES" },
    }
end

return M
