local vim = vim
local keymap = vim.keymap
local api = vim.api
local lsp = vim.lsp
local fn = vim.fn
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
    local ok, _ = pcall(api.nvim_buf_get_var, bufnr, get_option_var(client, option))
    return ok
end

-- }}}

local function set_handlers(
    _, --[[ client ]]
    _ --[[ bufnr ]]
)
    lsp.handlers["textDocument/references"] = lsp.with(lsp.handlers["textDocument/references"], {
        -- Use location list instead of quickfix list
        loclist = true,
    })
end

local function set_up_keymap(client, bufnr, format_enabled)
    local opts = { remap = true, silent = true, buffer = bufnr }
    local server_capabilities = client.server_capabilities

    if server_capabilities.completionProvider then
        api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
    end

    if server_capabilities.hoverProvider then
        api.nvim_buf_set_option(bufnr, "keywordprg", ":LspHover")
    end

    if server_capabilities.definitionProvider then
        keymap.set("n", "<leader>gd", "<Cmd>Lspsaga goto_definition<CR>", opts)
        keymap.set("n", "<leader>gp", "<cmd>Lspsaga peek_definition<CR>", opts)

        if options.get_option_value("lsp_tagfunc_enabled") then
            api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")
        elseif api.nvim_buf_get_option(bufnr, "tagfunc") == "v:lua.vim.lsp.tagfunc" then
            api.nvim_buf_set_option(bufnr, "tagfunc", "")
        end
    end

    if server_capabilities.documentFormattingProvider then
        if
            client.name == "null-ls" and is_null_ls_formatting_enabed(bufnr)
            or client.name ~= "null-ls"
        then
            api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
            keymap.set("n", "<leader>gq", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)
        else
            api.nvim_buf_set_option(bufnr, "formatexpr", "")
        end
    elseif format_enabled then
        api.nvim_buf_set_option(bufnr, "formatexpr", "")
    end

    if is_configured(bufnr, client, "shortcuts_set") then
        return
    end

    if server_capabilities.renameProvider then
        keymap.set("n", "<leader>gr", "<Cmd>Lspsaga rename<CR>", opts)
    end

    if server_capabilities.signatureHelpProvider then
        keymap.set("n", "<leader>gs", "<Cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    end

    if server_capabilities.declarationProvider then
        keymap.set("n", "<leader>gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    end

    if server_capabilities.implementationProvider then
        keymap.set("n", "<leader>gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    end

    if server_capabilities.referencesProvider then
        keymap.set("n", "<leader>gg", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    end

    keymap.set("n", "<leader>ge", "<cmd>Lspsaga show_line_diagnostics ++unfocus<CR>", opts)
    keymap.set("n", "<leader>gc", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts)
    keymap.set("n", "<leader>gl", "<cmd>lua vim.diagnostic.setloclist({open=true})<CR>", opts)

    if server_capabilities.documentSymbolProvider then
        keymap.set("n", "<leader>gds", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts)
    end

    if server_capabilities.workspaceSymbolProvider then
        keymap.set("n", "<leader>gw", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", opts)
    end

    if server_capabilities.codeActionProvider then
        keymap.set("n", "<leader>ga", "<cmd>Lspsaga code_action<CR>", opts)
    end

    if server_capabilities.documentRangeFormattingProvider then
        keymap.set("v", "<leader>gq", "<Esc><Cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
    end

    if server_capabilities.hoverProvider then
        api.nvim_command("command! -buffer -nargs=1 LspHover lua vim.lsp.buf.hover()<CR>")
    end

    set_enabled(bufnr, client, "shortcuts_set", true)
end

local function delete_keymaps(
    client,
    bufnr,
    _ --[[ format_enabled ]]
)
    local opts = { buffer = bufnr }
    local server_capabilities = client.server_capabilities
    local del_keymap = function(mode, rhs, _opts)
        if fn.maparg(rhs, mode) ~= "" then
            keymap.del(mode, rhs, _opts)
        end
    end

    if server_capabilities.completionProvider then
        api.nvim_buf_set_option(bufnr, "omnifunc", "")
    end

    if server_capabilities.hoverProvider then
        api.nvim_buf_set_option(bufnr, "keywordprg", "")
    end

    if server_capabilities.definitionProvider then
        del_keymap("n", "<leader>gd", opts)
        del_keymap("n", "<leader>gp", opts)

        if options.get_option_value("lsp_tagfunc_enabled") then
            api.nvim_buf_set_option(bufnr, "tagfunc", "")
        end
    end

    if server_capabilities.documentFormattingProvider then
        if
            client.name == "null-ls" and is_null_ls_formatting_enabed(bufnr)
            or client.name ~= "null-ls"
        then
            api.nvim_buf_set_option(bufnr, "formatexpr", "")
            del_keymap("n", "<leader>gq", opts)
        end
    end

    if is_configured(bufnr, client, "shortcuts_set") == false then
        return
    end

    if server_capabilities.renameProvider then
        del_keymap("n", "<leader>gr", opts)
    end

    if server_capabilities.signatureHelpProvider then
        del_keymap("n", "<leader>gs", opts)
    end

    if server_capabilities.declarationProvider then
        del_keymap("n", "<leader>gD", opts)
    end

    if server_capabilities.implementationProvider then
        del_keymap("n", "<leader>gi", opts)
    end

    if server_capabilities.referencesProvider then
        del_keymap("n", "<leader>gg", opts)
    end

    del_keymap("n", "<leader>ge", opts)
    del_keymap("n", "<leader>gc", opts)
    del_keymap("n", "<leader>gl", opts)

    if server_capabilities.documentSymbolProvider then
        del_keymap("n", "<leader>gds", opts)
    end

    if server_capabilities.workspaceSymbolProvider then
        del_keymap("n", "<leader>gw", opts)
    end

    if server_capabilities.codeActionProvider then
        del_keymap("n", "<leader>ga", opts)
    end

    if server_capabilities.documentRangeFormattingProvider then
        del_keymap("v", "<leader>gq", opts)
    end

    if server_capabilities.hoverProvider then
        pcall(api.nvim_buf_del_user_command, bufnr, "LspHover")
    end

    set_enabled(bufnr, client, "shortcuts_set", false)
end

local function setup_buffer_vars(client, bufnr, format_enabled)
    set_enabled(bufnr, client, "format_enabled", format_enabled)

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
                runtime_condition = function(params)
                    return options.get_option_value("lsp_completion_" .. name .. "_enabled")
                end,
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
                Text = lsp.protocol.CompletionItemKind["Text"],
                Method = lsp.protocol.CompletionItemKind["Method"],
                Function = lsp.protocol.CompletionItemKind["Function"],
                Constructor = lsp.protocol.CompletionItemKind["Constructor"],
                Field = lsp.protocol.CompletionItemKind["Field"],
                Variable = lsp.protocol.CompletionItemKind["Variable"],
                Class = lsp.protocol.CompletionItemKind["Class"],
                Interface = lsp.protocol.CompletionItemKind["Interface"],
                Module = lsp.protocol.CompletionItemKind["Module"],
                Property = lsp.protocol.CompletionItemKind["Property"],
                Unit = lsp.protocol.CompletionItemKind["Unit"],
                Value = lsp.protocol.CompletionItemKind["Value"],
                Enum = lsp.protocol.CompletionItemKind["Enum"],
                Keyword = lsp.protocol.CompletionItemKind["Keyword"],
                Snippet = lsp.protocol.CompletionItemKind["Snippet"],
                Color = lsp.protocol.CompletionItemKind["Color"],
                File = lsp.protocol.CompletionItemKind["File"],
                Reference = lsp.protocol.CompletionItemKind["Reference"],
                Folder = lsp.protocol.CompletionItemKind["Folder"],
                EnumMember = lsp.protocol.CompletionItemKind["EnumMember"],
                Constant = lsp.protocol.CompletionItemKind["Constant"],
                Struct = lsp.protocol.CompletionItemKind["Struct"],
                Event = lsp.protocol.CompletionItemKind["Event"],
                Operator = lsp.protocol.CompletionItemKind["Operator"],
                TypeParameter = lsp.protocol.CompletionItemKind["TypeParameter"],
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
    return next(lsp.get_clients({ bufnr = bufnr })) ~= nil
end

function M.setup_lsp()
    if vim.fn.exists("$VIMRC_DISABLE_LSP") == 1 then
        return
    end

    if vim.fn.exists(":LspInfo") == 0 then
        return
    end

    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            local bufnr = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            set_up_keymap(client, bufnr, is_enabled(bufnr, client, "format_enabled"))
        end,
    })

    vim.api.nvim_create_autocmd("LspDetach", {
        callback = function(args)
            local bufnr = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            delete_keymaps(client, bufnr, is_enabled(bufnr, client, "format_enabled"))
        end,
    })

    vim.diagnostic.config({
        signs = true,
        virtual_text = options.get_option_value("lsp_virtual_text", bufnr),
        underline = false,
        update_in_insert = false,
        severity_sort = false,
    })

    options.register_callback("lsp_virtual_text", function()
        vim.diagnostic.config({
            virtual_text = options.get_option_value("lsp_virtual_text", bufnr),
        })
    end)

    require("lspsaga").setup({
        symbol_in_winbar = {
            enable = false,
            separator = " ",
            ignore_patterns = {},
            hide_keyword = true,
            show_file = false,
            folder_level = 2,
            respect_root = false,
            color_mode = true,
        },
    })

    local setup = function(client, format_enabled)
        local bufnr = api.nvim_get_current_buf()

        if format_enabled == nil then
            format_enabled = true
        end

        setup_buffer_vars(client, bufnr, format_enabled)

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
        client.server_capabilities.documentFormattingProvider = false
        setup(client, false)
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
                        autoSearchPaths = true,
                        diagnosticMode = "openFilesOnly",
                        useLibraryCodeForTypes = true,
                    },
                },
            },
        })
    end

    if fn.executable("clangd") == 1 then
        local capabilities = lsp.protocol.make_client_capabilities()
        capabilities.offsetEncoding = { "utf-16" }
        lspconfig.clangd.setup({
            capabilities = capabilities,
            on_attach = setup_without_formatting,
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--completion-style=bundled",
                "--header-insertion=iwyu",
                "--inlay-hints",
                "--enable-config",
                "--offset-encoding=utf-16",
                "--header-insertion-decorators",
                "-j=1",
            },
        })
    end

    if fn.executable("lua-language-server") == 1 then
        lspconfig.lua_ls.setup({
            on_attach = setup_without_formatting,
            settings = {
                Lua = {
                    runtime = { library = api.nvim_list_runtime_paths()[1] },
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

    if fn.executable("gopls") == 1 then
        lspconfig.gopls.setup({
            on_attach = setup,
        })
    end

    if fn.executable("zls") == 1 then
        lspconfig.zls.setup({
            on_attach = setup,
            filetypes = { "zig" },
            cmd = {
                "zls",
                "--config-path",
                fn.expand("$HOME") .. "/.dotfiles/vim/zls_config.json",
            },
        })
    end

    if vim.fn.has("osx") == 1 then
        require("lspconfig").sourcekit.setup({
            filetypes = { "swift", "objcpp", "objc" },
            on_attach = setup,
        })
    end

    if fn.executable("vimls") == 1 then
        lspconfig.vimls.setup({
            on_attach = setup_without_formatting,
            filetypes = { "vim" },
        })
    end

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
            null_ls.builtins.formatting.stylua.with({
                extra_args = { "--config-path", fn.expand("$HOME") .. "/.dotfiles/vim/stylua.toml" },
            }),
            null_ls.builtins.formatting.cmake_format,
            null_ls.builtins.formatting.black,
            null_ls.builtins.formatting.rustfmt,
            null_ls.builtins.formatting.clang_format,
            null_ls.builtins.formatting.qmlformat,
            null_ls.builtins.formatting.swift_format,
            null_ls.builtins.formatting.prettier.with({
                filetypes = {
                    "javascript",
                    "javascriptreact",
                    "typescript",
                    "typescriptreact",
                    "vue",
                    "css",
                    "scss",
                    "less",
                    "html",
                    "jsonc",
                    "yaml",
                    "markdown.mdx",
                    "graphql",
                    "handlebars",
                },
            }),
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
            null_ls.builtins.diagnostics.cppcheck,
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

    setup_signs()
end

-- }}}

return M

-- vim: foldmethod=marker
