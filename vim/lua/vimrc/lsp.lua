local vim = vim
local api = vim.api
local lsp = vim.lsp
local lsp_utils = require "vimrc.lsp_utils"
local M = {}

function on_publish_diagnostics(u1, u2, params, client_id, u3, config)
    local bufnr = vim.uri_to_bufnr(params.uri)
    if not api.nvim_buf_is_loaded(bufnr) then return end

    lsp.diagnostic.on_publish_diagnostics(u1, u2, params, client_id, u3, config)

    local client = lsp.get_client_by_id(client_id)
    local loclist_enabled = api.nvim_buf_get_var(bufnr,
                                                 "vimrc_" .. client.name ..
                                                     "_lsp_location_list_enabled") ==
                                1

    if loclist_enabled == true then
        lsp_utils.set_loclist({
            bufnr = bufnr,
            open_loclist = false,
            client_id = client_id
        })
    end
end

function set_handlers(client, bufnr)
    local signs_enabled = api.nvim_buf_get_var(bufnr, "vimrc_" .. client.name ..
                                                   "_lsp_signs_enabled") == 1

    local virtual_text_enabled = api.nvim_buf_get_var(bufnr, "vimrc_" ..
                                                          client.name ..
                                                          "_lsp_virtual_text_enabled") ==
                                     1

    client.handlers["textDocument/publishDiagnostics"] =
        lsp.with(on_publish_diagnostics, {
            signs = signs_enabled,
            virtual_text = virtual_text_enabled,
            underline = false,
            update_in_insert = false
        })
end

function set_up_keymap(client, bufnr)
    local opts = {noremap = true, silent = true}
    local is_configured = api.nvim_buf_get_var(bufnr,
                                               "is_vimrc_" .. client.name ..
                                                   "_lsp_shortcuts_set")
    local filetype = api.nvim_buf_get_option(bufnr, "filetype")
    local resolved_capabilities = client.resolved_capabilities

    if resolved_capabilities.completion == true then
        api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
    end

    if resolved_capabilities.hover ~= false then
        api.nvim_buf_set_option(bufnr, "keywordprg", ":LspHover")
    end

    if is_configured then return end

    if resolved_capabilities.rename == true then
        api.nvim_buf_set_keymap(bufnr, "n", "gr",
                                "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)
    end

    if resolved_capabilities.signature_help == true and
        vim.fn.mapcheck("gs", "n") == 0 then
        api.nvim_buf_set_keymap(bufnr, "n", "gs",
                                "<Cmd>lua vim.lsp.buf.signature_help()<CR>",
                                opts)
    end

    if resolved_capabilities.goto_definition ~= false then
        api.nvim_buf_set_keymap(bufnr, "n", "gd",
                                "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
    end

    if resolved_capabilities.declaration == true then
        api.nvim_buf_set_keymap(bufnr, "n", "gD",
                                "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    end

    if resolved_capabilities.implementation == true then
        api.nvim_buf_set_keymap(bufnr, "n", "gi",
                                "<cmd>lua vim.lsp.buf.implementation()<CR>",
                                opts)
    end

    if resolved_capabilities.find_references ~= false then
        api.nvim_buf_set_keymap(bufnr, "n", "g*",
                                "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    end

    api.nvim_buf_set_keymap(bufnr, "n", "ge",
                            "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>",
                            opts)

    if resolved_capabilities.document_symbol ~= false then
        api.nvim_buf_set_keymap(bufnr, "n", "g0",
                                "<cmd>lua vim.lsp.buf.document_symbol()<CR>",
                                opts)
    end

    if resolved_capabilities.workspace_symbol ~= true then
        api.nvim_buf_set_keymap(bufnr, "n", "gw",
                                "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>",
                                opts)
    end

    if resolved_capabilities.code_action ~= false then
        api.nvim_buf_set_keymap(bufnr, "n", "ga",
                                "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    end

    if resolved_capabilities.document_formatting == true then
        api.nvim_buf_set_keymap(bufnr, "n", "gq",
                                "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    end

    if resolved_capabilities.hover ~= false then
        api.nvim_command(
            "command! -buffer -nargs=1 LspHover lua vim.lsp.buf.hover()<CR>")
    end

    api.nvim_buf_set_var(bufnr,
                         "is_vimrc_" .. client.name .. "_lsp_shortcuts_set",
                         true)
end

function setup_buffer_vars(client, bufnr)
    if vim.fn.exists("b:is_vimrc_" .. client.name .. "_lsp_auto_stop") == 0 then
        api.nvim_buf_set_var(bufnr,
                             "is_vimrc_" .. client.name .. "_lsp_auto_stop",
                             false)
    end

    if vim.fn.exists("b:is_vimrc_" .. client.name .. "_lsp_shortcuts_set") == 0 then
        api.nvim_buf_set_var(bufnr, "is_vimrc_" .. client.name ..
                                 "_lsp_shortcuts_set", false)
    end

    if vim.fn.exists("b:is_vimrc_" .. client.name .. "_lsp_events_set") == 0 then
        api.nvim_buf_set_var(bufnr,
                             "is_vimrc_" .. client.name .. "_lsp_events_set",
                             false)
    end

    if vim.fn.exists("b:vimrc_" .. client.name .. "_lsp_location_list_enabled") ==
        0 then
        api.nvim_buf_set_var(bufnr, "vimrc_" .. client.name ..
                                 "_lsp_location_list_enabled", true)
    end

    if vim.fn.exists("b:vimrc_" .. client.name .. "_lsp_signs_enabled") == 0 then
        api.nvim_buf_set_var(bufnr,
                             "vimrc_" .. client.name .. "_lsp_signs_enabled",
                             true)
    end

    if vim.fn.exists("b:vimrc_" .. client.name .. "_lsp_virtual_text_enabled") ==
        0 then
        api.nvim_buf_set_var(bufnr, "vimrc_" .. client.name ..
                                 "_lsp_virtual_text_enabled", true)
    end
end

M.print_buffer_clients = function(bufnr)
    print(vim.inspect(lsp.buf_get_clients(bufnr)))
end

M.is_lsp_running = function(bufnr) return
    next(lsp.buf_get_clients(bufnr)) ~= nil end

M.stop_buffer_clients =
    function(client_id, bufnr) lsp.stop_client(client_id) end

M.setup_lsp = function()
    if vim.fn.exists(":LspInfo") == 0 then
        return
    end

    local setup = function(client)
        local bufnr = api.nvim_get_current_buf()

        setup_buffer_vars(client, bufnr)
        set_up_keymap(client, bufnr)
        set_handlers(client, bufnr)
    end

    local setup_without_formatting = function(client)
        client.resolved_capabilities.document_formatting = false
        setup(client)
    end

    local lspconfig = require 'lspconfig'

    lspconfig.pyright.setup {
        on_attach = setup_without_formatting,
        filetypes = {"python"},
        settings = {
            python = {
                analysis = {
                    reportImportCycles = "error",
                    reportUnusedImport = "error",
                    reportUnusedClass = "error",
                    reportUnusedFunction = "error",
                    reportUnusedVariable = "error",
                    reportDuplicateImport = "error"
                }
            }
        }
    }
    lspconfig.clangd.setup{
        on_attach=setup_without_formatting,
        filetypes={"cpp", "c"},
        cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--completion-style=detailed",
            "--recovery-ast",
        }
    }
    lspconfig.rls.setup {
        on_attach = setup_without_formatting,
        filetypes = {"rust"}
    }
    lspconfig.vimls.setup {
        on_attach = setup_without_formatting,
        filetypes = {"vim"}
    }
    lspconfig.efm.setup {on_attach = setup}
end

return M

-- vim: foldmethod=marker
