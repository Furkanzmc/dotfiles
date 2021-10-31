local vim = vim
local api = vim.api
local lsp = vim.lsp
local fn = vim.fn
local utils = require("vimrc.utils")
local map = require("futils").map
local log = require("futils.log")
local null_ls_sources = require("vimrc.null_ls_sources")
local M = {}

-- Local Functions {{{

-- Utils {{{

local function get_option_var(client, option)
    local name = string.gsub(client.name, "-", "_")
    return "vimrc_" .. name .. "_lsp_" .. option
end

local function is_enabled(bufnr, client, option)
    local ok, value = pcall(api.nvim_buf_get_var, bufnr, get_option_var(client, option))
    if ok then
        return value == 1 or value == true
    end

    return false
end

local function set_enabled(bufnr, client, option, enabled)
    return api.nvim_buf_set_var(bufnr, get_option_var(client, option), enabled)
end

local function option_exists(bufnr, client, option)
    local ok, value = pcall(api.nvim_buf_get_var, bufnr, get_option_var(client, option))
    return ok
end

-- Taken from vim/lsp/doagnostic.lua from v0.5.0-832-g35325ddac
-- Sets the location list
-- @param opts table|nil Configuration table. Keys:
--   - {open_loclist}: (boolean, default true)
--     - Open loclist after set
--   - {client_id}: (number)
--     - If nil, will consider all clients attached to buffer.
--   - {severity}: (DiagnosticSeverity)
--     - Exclusive severity to consider. Overrides {severity_limit}
--   - {severity_limit}: (DiagnosticSeverity)
--     - Limit severity of diagnostics found. E.g. "Warning" means { "Error", "Warning" } will be valid.
local function update_loc_list(opts)
    opts = opts or {}
    assert(opts.client_id ~= nil, "client_id is required.")
    assert(opts.bufnr ~= nil, "bufnr is required.")

    local open_loclist = vim.F.if_nil(opts.open_loclist, true)

    local bufnr = api.nvim_get_current_buf()
    local buffer_diags = lsp.diagnostic.get(bufnr, opts.client_id)
    local client = lsp.get_client_by_id(opts.client_id)

    local severity = utils.to_severity(opts.severity)
    local severity_limit = utils.to_severity(opts.severity_limit)

    local items = {}
    local insert_diag = function(diag)
        if severity then
            -- Handle missing severities
            if not diag.severity then
                return
            end

            if severity ~= diag.severity then
                return
            end
        elseif severity_limit then
            if not diag.severity then
                return
            end

            if severity_limit < diag.severity then
                return
            end
        end

        local pos = diag.range.start
        local row = pos.line
        local col = lsp.util.character_offset(bufnr, row, pos.character)

        local line = api.nvim_buf_get_lines(bufnr, row, row + 1, false)
        if line == nil then
            line = "N/A"
        else
            line = line[1]
        end

        table.insert(items, {
            bufnr = bufnr,
            lnum = row + 1,
            col = col + 1,
            context = 320,
            text = "[" .. client.name .. "]" .. " | " .. line .. " | " .. diag.message,
            type = utils.loclist_type_map[diag.severity or DiagnosticSeverity.Error] or "E",
        })
    end

    for _, diag in ipairs(buffer_diags) do
        insert_diag(diag)
    end

    utils.set_loclist(opts.bufnr, client.name, items, "LSP")
    if open_loclist then
        vim.cmd([[lopen]])
    end
end

-- }}}

local function on_publish_diagnostics(u1, result, ctx, config)
    local bufnr = vim.uri_to_bufnr(result.uri)
    if not api.nvim_buf_is_loaded(bufnr) then
        return
    end

    local client = lsp.get_client_by_id(ctx.client_id)
    if not is_enabled(bufnr, client, "configured") then
        return
    end

    lsp.diagnostic.on_publish_diagnostics(u1, result, ctx, config)

    if is_enabled(bufnr, client, "location_list_enabled") == true then
        update_loc_list({
            bufnr = bufnr,
            open_loclist = false,
            client_id = ctx.client_id,
        })
    end
end

local function set_handlers(client, bufnr)
    client.handlers["textDocument/publishDiagnostics"] = lsp.with(on_publish_diagnostics, {
        signs = is_enabled(bufnr, client, "signs_enabled"),
        virtual_text = is_enabled(bufnr, client, "virtual_text_enabled"),
        underline = false,
        update_in_insert = false,
        severity_sort = true,
    })
end

local function set_up_keymap(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    local filetype = api.nvim_buf_get_option(bufnr, "filetype")
    local resolved_capabilities = client.resolved_capabilities

    if resolved_capabilities.completion == true then
        api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
    end

    if resolved_capabilities.hover ~= false then
        api.nvim_buf_set_option(bufnr, "keywordprg", ":LspHover")
    end

    if is_enabled(bufnr, client, "shortcuts_set") then
        return
    end

    if resolved_capabilities.rename == true then
        map("n", "gr", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)
    end

    if resolved_capabilities.signature_help == true and vim.fn.mapcheck("gs", "n") == 0 then
        map("n", "gs", "<Cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    end

    if resolved_capabilities.goto_definition ~= false then
        map("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
    end

    if resolved_capabilities.declaration == true then
        map("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    end

    if resolved_capabilities.implementation == true then
        map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    end

    if resolved_capabilities.find_references ~= false then
        map("n", "g*", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    end

    map("n", "ge", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)

    if resolved_capabilities.document_symbol ~= false then
        map("n", "g0", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts)
    end

    if resolved_capabilities.workspace_symbol ~= true then
        map("n", "gw", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", opts)
    end

    if resolved_capabilities.code_action ~= false then
        map("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    end

    if resolved_capabilities.document_formatting == true then
        map("n", "gq", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    end

    if resolved_capabilities.hover ~= false then
        api.nvim_command("command! -buffer -nargs=1 LspHover lua vim.lsp.buf.hover()<CR>")
    end

    set_enabled(bufnr, client, "shortcuts_set", true)
end

local function setup_buffer_vars(client, bufnr)
    if option_exists(bufnr, client, "auto_stop") then
        set_enabled(bufnr, client, "auto_stop", false)
    end

    if option_exists(bufnr, client, "shortcuts_set") then
        set_enabled(bufnr, client, "shortcuts_set", false)
    end

    if option_exists(bufnr, client, "events_set") then
        set_enabled(bufnr, client, "events_set", false)
    end

    if option_exists(bufnr, client, "location_list_enabled") == 0 then
        set_enabled(bufnr, client, "location_list_enabled", true)
    end

    if option_exists(bufnr, client, "signs_enabled") then
        set_enabled(bufnr, client, "signs_enabled", true)
    end

    if option_exists(bufnr, client, "virtual_text_enabled") then
        set_enabled(bufnr, client, "virtual_text_enabled", true)
    end
end

local function setup_signs()
    vim.cmd([[sign define DiagnosticSignError text=✖ texthl=DiagnosticError linehl= numhl=]])
    vim.cmd([[sign define DiagnosticSignWarn text=‼ texthl=DiagnosticWarn linehl= numhl=]])
    vim.cmd([[sign define DiagnosticSignInfo text=ℹ texthl=DiagnosticInfo linehl= numhl=]])
    vim.cmd([[sign define DiagnosticSignHint text=⦿ texthl=DiagnosticHint linehl= numhl=]])
end

-- }}}

-- Public Functions {{{

function M.print_buffer_clients(bufnr)
    print(vim.inspect(lsp.buf_get_clients(bufnr)))
end

function M.is_lsp_running(bufnr)
    return next(lsp.buf_get_clients(bufnr)) ~= nil
end

function M.stop_buffer_clients(client_id, bufnr)
    lsp.stop_client(client_id)
end

function M.setup_lsp()
    if vim.fn.exists("$VIMRC_DISABLE_LSP") == 1 then
        return
    end

    if vim.fn.exists(":LspInfo") == 0 then
        return
    end

    local setup = function(client)
        local bufnr = api.nvim_get_current_buf()

        setup_buffer_vars(client, bufnr)
        set_up_keymap(client, bufnr)

        set_enabled(bufnr, client, "configured", true)
        set_handlers(client, bufnr)
        require("lsp_signature").on_attach({
            bind = true,
            handler_opts = { border = "none" },
            toggle_key = "<C-g><C-s>",
            extra_trigger_chars = { "{", "}" },
        }, bufnr)
    end

    local setup_without_formatting = function(client)
        client.resolved_capabilities.document_formatting = false
        setup(client)
    end

    local lspconfig = require("lspconfig")
    lsp.set_log_level("error")

    if fn.executable("pyright") == 1 then
        lspconfig.pyright.setup({
            on_attach = setup_without_formatting,
            filetypes = { "python" },
            settings = {
                python = {
                    analysis = {
                        reportImportCycles = "error",
                        reportUnusedImport = "error",
                        reportUnusedClass = "error",
                        reportUnusedFunction = "error",
                        reportUnusedVariable = "error",
                        reportDuplicateImport = "error",
                    },
                },
            },
        })
    end

    if fn.executable("clangd") == 1 then
        lspconfig.clangd.setup({
            on_attach = setup_without_formatting,
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--completion-style=detailed",
                "--recovery-ast",
                "--header-insertion=iwyu",
                "--header-insertion-decorators",
                "-j=1",
            },
        })
    end

    local sumneko_bin_path = vim.fn.expand("$SUMNEKO_BIN_PATH")
    if sumneko_bin_path ~= "" then
        local sumneko_binary = sumneko_bin_path .. "/lua-language-server"
        local runtime_path = vim.split(package.path, ";")
        table.insert(runtime_path, "lua/?.lua")
        table.insert(runtime_path, "lua/?/init.lua")

        lspconfig.sumneko_lua.setup({
            cmd = { sumneko_binary, "-E", sumneko_bin_path .. "/main.lua" },
            on_attach = setup_without_formatting,
            settings = {
                Lua = {
                    runtime = { path = runtime_path },
                    diagnostics = { globals = { "vim" } },
                    workspace = { library = api.nvim_get_runtime_file("", true) },
                    telemetry = { enable = false },
                },
            },
        })
    end

    if fn.executable("ccls") == 1 then
        lspconfig.ccls.setup({
            on_attach = setup_without_formatting,
            settings = { index = { threads = 1 } },
        })
    end

    if fn.executable("rust-analyzer") == 1 then
        lspconfig.rust_analyzer.setup({
            on_attach = setup_without_formatting,
            filetypes = { "rust" },
            settings = {
                ["rust-analyzer"] = {
                    assist = {
                        importMergeBehavior = "last",
                        importPrefix = "by_self",
                    },
                    cargo = { loadOutDirsFromCheck = true },
                    procMacro = { enable = true },
                },
            },
        })
    end

    if fn.executable("vimls") == 1 then
        lspconfig.vimls.setup({
            on_attach = setup_without_formatting,
            filetypes = { "vim" },
        })
    end

    local unused_pyright_config = {
        lintCommand = "pyright",
        lintStdin = false,
        lintIgnoreExitCode = true,
        lintFormats = {
            "%t%n:%f:%l:%c %m",
            "%-P%f",
            "  %#%l:%c - %# %tarning: %m",
            "  %#%l:%c - %# %trror: %m",
            "    %Eerror %m",
            "    %C%\\s%+%m",
        },
    }

    local null_ls = require("null-ls")
    null_ls.config({
        debug = true,
        sources = {
            -- Builtin sources {{{
            null_ls.builtins.formatting.stylua,
            null_ls.builtins.formatting.cmake_format,
            null_ls.builtins.formatting.black,
            null_ls.builtins.formatting.rustfmt,
            null_ls.builtins.formatting.clang_format,
            null_ls.builtins.hover.dictionary,
            null_ls.builtins.diagnostics.pylint.with({
                condition = function(_)
                    return fn.expand("$VIMRC_PYLINT_DISABLE") == ""
                end,
            }),
            null_ls.builtins.diagnostics.yamllint,
            -- }}}
            -- Custom sources {{{
            null_ls_sources.hover.pylint_error,
            null_ls_sources.diagnostics.jq,
            null_ls_sources.formatting.jq,
            null_ls_sources.formatting.qmlformat,
            null_ls_sources.diagnostics.qmllint,
            null_ls_sources.diagnostics.cmake_lint,
            null_ls_sources.completion.buffers,
            -- }}}
        },
    })
    lspconfig["null-ls"].setup({ on_attach = setup })

    setup_signs()
end

-- }}}

return M

-- vim: foldmethod=marker
