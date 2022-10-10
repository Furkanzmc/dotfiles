local vim = vim
local api = vim.api
local lsp = vim.lsp
local fn = vim.fn
local utils = require("vimrc.utils")
local map = require("vimrc").map
local null_ls_sources = require("vimrc.null_ls_sources")
local options = require("options")
local M = {}

-- Local Functions {{{

-- Utils {{{

local function is_null_ls_formatting_enabed(bufnr)
    local file_type = api.nvim_buf_get_option(bufnr, "filetype")
    local generators = require("null-ls.generators").get_available(
        file_type,
        require("null-ls.methods").internal.FORMATTING
    )
    return #generators > 0
end

local function get_option_var(client, option)
    local name = string.gsub(client.name, "-", "_")
    return "vimrc_" .. name .. "_lsp_" .. option
end

local function is_enabled(bufnr, client, option)
    local ok, value = pcall(api.nvim_buf_get_var, bufnr, get_option_var(client, option))
    if ok then
        return value == 1 or value == true
    end

    return true
end

local function is_configured(bufnr, client, option)
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

-- }}}

local function set_handlers(client, bufnr)
    vim.lsp.handlers["textDocument/references"] = vim.lsp.with(
        vim.lsp.handlers["textDocument/references"],
        {
            -- Use location list instead of quickfix list
            loclist = true,
        }
    )
end

local function set_up_keymap(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    local server_capabilities = client.server_capabilities

    if server_capabilities.completionProvider then
        api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
    end

    if server_capabilities.hoverProvider then
        api.nvim_buf_set_option(bufnr, "keywordprg", ":LspHover")
    end

    if is_configured(bufnr, client, "shortcuts_set") then
        return
    end

    if server_capabilities.renameProvider then
        map("n", "<leader>gr", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)
    end

    if server_capabilities.signatureHelpProvider then
        map("n", "<leader>gs", "<Cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    end

    if server_capabilities.definitionProvider then
        map("n", "<leader>gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
        if options.get_option_value("lsp_tagfunc_enabled") then
            api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")
        elseif api.nvim_buf_get_option(bufnr, "tagfunc") == "v:lua.vim.lsp.tagfunc" then
            api.nvim_buf_set_option(bufnr, "tagfunc", "")
        end
    end

    if server_capabilities.declarationProvider then
        map("n", "<leader>gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    end

    if server_capabilities.implementationProvider then
        map("n", "<leader>gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    end

    if server_capabilities.referencesProvider then
        map("n", "<leader>gg", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    end

    map("n", "<leader>ge", "<cmd>lua vim.diagnostic.open_float(0, {scope='line'})<CR>", opts)
    map("n", "<leader>gE", "<cmd>lua vim.diagnostic.setloclist({open=true})<CR>", opts)

    if server_capabilities.documentSymbolProvider then
        map("n", "<leader>gds", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts)
    end

    if server_capabilities.workspaceSymbolProvider then
        map("n", "<leader>gw", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", opts)
    end

    if server_capabilities.codeActionProvider then
        map("n", "<leader>ga", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    end

    if server_capabilities.documentFormattingProvider then
        if
            client.name == "null-ls" and is_null_ls_formatting_enabed(bufnr)
            or client.name ~= "null-ls"
        then
            api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
            map("n", "<leader>gq", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)
        else
            api.nvim_buf_set_option(bufnr, "formatexpr", "")
        end
    end

    if server_capabilities.documentRangeFormattingProvider then
        map("v", "<leader>gq", "<Esc><Cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
    end

    if server_capabilities.hoverProvider then
        api.nvim_command("command! -buffer -nargs=1 LspHover lua vim.lsp.buf.hover()<CR>")
    end

    set_enabled(bufnr, client, "shortcuts_set", true)
end

local function setup_buffer_vars(client, bufnr)
    if not option_exists(bufnr, client, "auto_stop") then
        set_enabled(bufnr, client, "auto_stop", false)
    end

    if not option_exists(bufnr, client, "shortcuts_set") then
        set_enabled(bufnr, client, "shortcuts_set", false)
    end

    if not option_exists(bufnr, client, "events_set") then
        set_enabled(bufnr, client, "events_set", false)
    end

    if not option_exists(bufnr, client, "signs_enabled") then
        set_enabled(bufnr, client, "signs_enabled", true)
    end

    if not option_exists(bufnr, client, "virtual_text_enabled") then
        set_enabled(bufnr, client, "virtual_text_enabled", true)
    end
end

local function setup_signs()
    vim.cmd([[sign define DiagnosticSignError text=✖ texthl=DiagnosticError linehl= numhl=]])
    vim.cmd([[sign define DiagnosticSignWarn text=‼ texthl=DiagnosticWarn linehl= numhl=]])
    vim.cmd([[sign define DiagnosticSignInfo text=ℹ texthl=DiagnosticInfo linehl= numhl=]])
    vim.cmd([[sign define DiagnosticSignHint text=⦿ texthl=DiagnosticHint linehl= numhl=]])
end

local function setup_null_ls_cmp_patch()
    -- FIXME:
    -- [ ] Some sources rely on their own custom keyword patterns. For example, this prevents
    -- cmp-calc from working properly. Or cmp-path cannot complete hidden directories becauase of
    -- it.
    -- [ ] cmp-emoji source doesn't work.
    package.loaded["cmp"] = {
        register_source = function(name, source)
            local get_bufnrs = function()
                local bufs = {}
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    bufs[vim.api.nvim_win_get_buf(win)] = true
                end
                return vim.tbl_keys(bufs)
            end

            require("null-ls.init").register(require("null-ls.helpers").make_builtin({
                method = require("null-ls.methods").internal.COMPLETION,
                filetypes = {},
                name = name,
                generator = {
                    name = name,
                    fn = function(params, done)
                        local regex = vim.regex("\\k*$")
                        local line = params.content[params.row]
                        local pos = api.nvim_win_get_cursor(0)
                        params.line_to_cursor = line:sub(1, pos[2])
                        params.offset = regex:match_str(params.line_to_cursor) + 1
                        params.option = params.option or { get_bufnrs = get_bufnrs }
                        params.context = params.context
                            or {
                                cursor_before_line = params.line_to_cursor,
                                bufnr = params.bufnr,
                            }
                        source:complete(params, function(result)
                            if result == nil then
                                done({ { items = {}, isIncomplete = true } })
                            elseif result.items == nil then
                                done({
                                    {
                                        items = result,
                                        isIncomplete = #result == 0,
                                    },
                                })
                            else
                                done({ result })
                            end
                        end)
                    end,
                    async = true,
                },
            }))
        end,
        lsp = {
            CompletionItemKind = {
                Text = vim.lsp.protocol.CompletionItemKind["Text"],
                Method = vim.lsp.protocol.CompletionItemKind["Method"],
                Function = vim.lsp.protocol.CompletionItemKind["Function"],
                Constructor = vim.lsp.protocol.CompletionItemKind["Constructor"],
                Field = vim.lsp.protocol.CompletionItemKind["Field"],
                Variable = vim.lsp.protocol.CompletionItemKind["Variable"],
                Class = vim.lsp.protocol.CompletionItemKind["Class"],
                Interface = vim.lsp.protocol.CompletionItemKind["Interface"],
                Module = vim.lsp.protocol.CompletionItemKind["Module"],
                Property = vim.lsp.protocol.CompletionItemKind["Property"],
                Unit = vim.lsp.protocol.CompletionItemKind["Unit"],
                Value = vim.lsp.protocol.CompletionItemKind["Value"],
                Enum = vim.lsp.protocol.CompletionItemKind["Enum"],
                Keyword = vim.lsp.protocol.CompletionItemKind["Keyword"],
                Snippet = vim.lsp.protocol.CompletionItemKind["Snippet"],
                Color = vim.lsp.protocol.CompletionItemKind["Color"],
                File = vim.lsp.protocol.CompletionItemKind["File"],
                Reference = vim.lsp.protocol.CompletionItemKind["Reference"],
                Folder = vim.lsp.protocol.CompletionItemKind["Folder"],
                EnumMember = vim.lsp.protocol.CompletionItemKind["EnumMember"],
                Constant = vim.lsp.protocol.CompletionItemKind["Constant"],
                Struct = vim.lsp.protocol.CompletionItemKind["Struct"],
                Event = vim.lsp.protocol.CompletionItemKind["Event"],
                Operator = vim.lsp.protocol.CompletionItemKind["Operator"],
                TypeParameter = vim.lsp.protocol.CompletionItemKind["TypeParameter"],
            },
        },
        -- FIXME: lsp_signature relies on this function.
        visible = function()
            return vim.fn.pumvisible() ~= 0
        end,
    }
end

-- }}}

-- Public Functions {{{

function M.is_lsp_running(bufnr)
    return next(lsp.buf_get_clients(bufnr)) ~= nil
end

function M.setup_lsp()
    if vim.fn.exists("$VIMRC_DISABLE_LSP") == 1 then
        return
    end

    if vim.fn.exists(":LspInfo") == 0 then
        return
    end

    vim.diagnostic.config({
        signs = true,
        virtual_text = false,
        underline = false,
        update_in_insert = false,
        severity_sort = true,
    })

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
        client.server_capabilities.documentFormattingProvider = {}
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
                "--completion-style=bundled",
                "--header-insertion=iwyu",
                "--inlay-hints",
                "--offset-encoding=utf-8",
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

    local cmp_exists, _ = pcall(require, "cmp")
    if not cmp_exists then
        setup_null_ls_cmp_patch()
    end

    local null_ls = require("null-ls")
    null_ls.setup({
        debug = vim.fn.expand("$VIMRC_NULL_LS_DEBUG") == "1",
        update_on_insert = false,
        on_attach = setup,
        sources = {
            -- Builtin formatting sources {{{
            null_ls.builtins.formatting.stylua,
            null_ls.builtins.formatting.cmake_format,
            null_ls.builtins.formatting.black,
            null_ls.builtins.formatting.rustfmt,
            null_ls.builtins.formatting.clang_format,
            null_ls.builtins.formatting.qmlformat,
            -- }}}
            -- Builtin hover sources {{{
            -- }}}
            -- Builtin diagnostics sources {{{
            null_ls.builtins.diagnostics.pylint.with({
                runtime_condition = function(params)
                    return options.get_option_value("pylint_enabled", params.bufnr)
                end,
            }),
            null_ls.builtins.diagnostics.yamllint,
            null_ls.builtins.diagnostics.qmllint.with({
                runtime_condition = function(params)
                    return options.get_option_value("qmllint_enabled", params.bufnr)
                end,
            }),
            -- }}}
            -- Custom sources {{{
            null_ls_sources.hover.pylint_error,
            null_ls_sources.hover.zettel_context,
            null_ls_sources.diagnostics.jq,
            null_ls_sources.formatting.jq,
            null_ls_sources.diagnostics.cmake_lint,
            -- }}}
            -- Builtin completion sources {{{
            null_ls.builtins.completion.tags.with({
                generator_opts = {
                    runtime_condition = function(params)
                        return options.get_option_value("tags_completion_enabled", params.bufnr)
                            == true
                    end,
                },
            }),
            null_ls.builtins.completion.spell.with({
                generator_opts = {
                    runtime_condition = function(_)
                        return vim.opt_local.spell:get()
                    end,
                },
            }),
            -- }}}
        },
    })
    vim.cmd(
        [[packadd cmp-buffer | lua require('cmp').register_source('buffer', require('cmp_buffer').new())]]
    )
    vim.cmd(
        [[packadd cmp-path | lua require('cmp').register_source('path', require('cmp_path').new())]]
    )
    if vim.fn.expand("$VIMRC_LSP_TREESITTER_ENABLED") == 1 then
        vim.cmd(
            [[packadd cmp-treesitter | lua require('cmp').register_source('treesitter', require('cmp_treesitter').new())]]
        )
    end

    setup_signs()
end

-- }}}

return M

-- vim: foldmethod=marker
