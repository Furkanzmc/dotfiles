-- Initial config from: https://jip.dev/posts/a-simpler-vim-statusline/
local vim = vim
local api = vim.api
local fn = vim.fn
local opt_local = vim.opt_local
local g = vim.g
local buffers = require("vimrc.buffers")
local M = {}

-- Utility Functions {{{

local function statusline_mode(abbvr)
    if abbvr == "n" then
        return "Normal"
    end
    if abbvr == "no" then
        return "N.Operator Pending "
    end
    if abbvr == "v" then
        return "Visual"
    end
    if abbvr == "V" then
        return "V.Line"
    end
    if abbvr == "" then
        return "V.Block"
    end
    if abbvr == "s" then
        return "Select"
    end
    if abbvr == "S" then
        return "S.Line"
    end
    if abbvr == "\\<C-S>" then
        return "S.Block"
    end
    if abbvr == "i" then
        return "Insert"
    end
    if abbvr == "R" then
        return "Replace"
    end
    if abbvr == "Rv" then
        return "V.Replace"
    end
    if abbvr == "c" then
        return "Command"
    end
    if abbvr == "cv" then
        return "Vim Ex"
    end
    if abbvr == "ce" then
        return "Ex"
    end
    if abbvr == "r" then
        return "Prompt"
    end
    if abbvr == "rm" then
        return "More"
    end
    if abbvr == "r?" then
        return "Confirm"
    end
    if abbvr == "!" then
        return "Shell"
    end
    if abbvr == "t" then
        return "Terminal"
    end
    if abbvr == "nt" then
        return "N. Terminal"
    end
end

local function color(str, active, active_color, inactive_color, padding)
    if padding == nil then
        padding = 0
    end

    local cl = "%#" .. inactive_color .. "#"
    if active then
        cl = "%#" .. active_color .. "#"
    end

    return cl .. string.rep(" ", padding) .. str .. string.rep(" ", padding) .. "%0*"
end

local function lsp_dianostics(active, bufnr)
    local lsp_errors = #vim.diagnostic.get(bufnr, {
        severity = vim.diagnostic.severity.ERROR,
    })
    local lsp_warnings = #vim.diagnostic.get(bufnr, {
        severity = vim.diagnostic.severity.WARN,
    })
    local lsp_hints = #vim.diagnostic.get(bufnr, {
        severity = vim.diagnostic.severity.HINT,
    })
    local lsp_info = #vim.diagnostic.get(bufnr, {
        severity = vim.diagnostic.severity.INFO,
    })

    local status = {}
    if lsp_errors > 0 then
        table.insert(
            status,
            color("✖ " .. lsp_errors, active, "StatusLineError", "StatusLineNC", 1)
        )
    end

    if lsp_warnings > 0 then
        table.insert(
            status,
            color("‼ " .. lsp_warnings, active, "StatusLineWarning", "StatusLineNC", 1)
        )
    end

    if lsp_hints > 0 then
        table.insert(
            status,
            color("⦿ " .. lsp_hints, active, "StatusLineHint", "StatusLineNC", 1)
        )
    end

    if lsp_info > 0 then
        table.insert(status, color("ℹ " .. lsp_info, active, "StatusLineInfo", "StatusLineNC", 1))
    end

    return table.concat(status, "|")
end

-- }}}

-- Global Functions {{{

function _G.is_fugitive_buffer(bufnr)
    return pcall(api.nvim_buf_get_var, bufnr, "fugitive_type")
        or string.match(fn.expand("%"), "^diffview") ~= nil
end

function _G.statusline(txt, padding)
    if txt == "" or txt == nil then
        return ""
    end

    return string.rep(" ", padding) .. txt .. string.rep(" ", padding)
end

-- }}}

function M.init(winnr)
    local active = winnr == fn.win_getid()
    local bufnr = fn.bufnr()
    local status = {}
    local st = function(str, active, active_color, inactive_color, padding)
        if str ~= "" then
            table.insert(status, color(str, active, active_color, inactive_color, padding))
        end
    end

    -- Left side {{{

    -- Mode sign {{{

    if active and _G.is_fugitive_buffer(bufnr) then
        st("FUGITIVE", active, "StatusLineMode", "StatusLineNC", 1)
        st("|", active, "StatusLineMode", "StatusLineNC")
    end

    if active then
        st(
            string.upper(statusline_mode(vim.fn.mode())),
            active,
            "StatusLineMode",
            "StatusLineNC",
            1
        )
    end

    -- }}}

    -- Help, Quickfix, and Preview signs {{{

    st(
        '%{&filetype == "help" ? " [Help] " : (&previewwindow ? " [Preview] " : "")}',
        active,
        "StatusLineSpecialWindow",
        "StatusLineTermNC"
    )

    st(
        '%{exists("w:quickfix_title") ? " " . w:quickfix_title : ""}',
        active,
        "StatusLineSpecialWindow",
        "StatusLineTermNC"
    )

    -- }}}

    -- File path {{{

    if _G.is_fugitive_buffer(bufnr) then
        st(fn.fnamemodify(fn.bufname(bufnr), ":t"), active, "StatusLineFilePath", "StatusLineNC", 1)
    else
        st("%<%f", active, "StatusLineFilePath", "StatusLineNC", 1)
    end

    -- }}}

    -- LSP Status {{{

    local is_lsp_running = require("vimrc.lsp").is_lsp_running(bufnr)
    if active and is_lsp_running then
        st("가", active, "StatusLineLspStatus", "StatusLineNC", 1)
    end

    -- }}}

    -- Diff file signs {{{

    local buffer_git_tag = {
        "%{",
        "!&diff ? '' : ",
        "(luaeval('_G.is_fugitive_buffer(vim.fn.bufnr())') ? '[head]' : '[local]')",
        "}",
    }

    st(table.concat(buffer_git_tag), active, "StatusDiffFileSign", "StatusDiffFileSignNC")

    -- }}}

    -- Read only and spell sign {{{

    st("%r", active, "StatusLineError", "StatusLineNC")
    if opt_local.spell:get() then
        st("☰", active, "StatusLineError", "StatusLineNC", 1)
    end

    -- }}}

    -- Modified sign {{{

    st("%{&modified ? ' +' : ''}", active, "StatusLineModified", "StatusLineNC", active and 0 or 1)
    if active then
        -- Code from: https://vi.stackexchange.com/a/14313
        local modified_buf_count = buffers.get_modified_buf_count(-1, { bufnr })
        if modified_buf_count > 0 then
            st(
                "[✎ " .. modified_buf_count .. "]",
                active,
                "StatusLineModified",
                "StatusLineNC",
                1
            )
        else
            st("%{&modified ? ' ' : ''}", active, "StatusLineModified", "StatusLineNC")
        end
    end

    -- }}}

    -- }}}

    -- Right side {{{

    table.insert(status, "%=")

    -- LSP Diagnostic {{{

    if is_lsp_running and active then
        table.insert(status, lsp_dianostics(active, bufnr))
    end

    -- }}}

    -- HTTP Request Status {{{

    if active and fn.exists(":SendHttpRequest") > 0 and g.nvim_http_request_in_progress == true then
        st("[Http]", active, "StatusLineLspStatus", "StatusLineNC", 1)
    end

    -- }}}

    -- Line and column {{{

    if active then
        st("[%l:%c]", active, "StatusLineRowColumn", "StatusLineNC", 1)
    end

    -- }}}

    -- Branch name {{{

    if fn.exists("*FugitiveHead") > 0 and active then
        local head = fn["FugitiveHead"]()
        -- if head == "" and fn.exists("*FugitiveDetect") > 0 and fn.exists("b:git_dir") == 0 then
        --     fn["FugitiveDetect"](fn.expand("%"))
        --     head = fn["fugitive#head"]()
        -- end

        if head ~= "" then
            st(" " .. head, active, "StatusLineBranch", "StatusLineNC", 1)
        end
    end

    -- }}}

    -- }}}

    return table.concat(status)
end

return M

-- vim: foldmethod=marker
