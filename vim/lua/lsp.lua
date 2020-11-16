local vim = vim
local lsp = vim.lsp
local M = {}


function publish_to_location_list(bufnr, local_result)
    if local_result and local_result.diagnostics then
        for _, v in ipairs(local_result.diagnostics) do
            v.uri = v.uri or local_result.uri
        end
    end

    -- TODO: Clear only the items that we add here so we can share the location
    -- list with others.
    local locations = lsp.util.locations_to_items(local_result.diagnostics)
    vim.fn.setloclist(
        bufnr,
        locations,
        "r")
end

function publish_diagnostics(bufnr)
    local api = vim.api
    lsp.handlers["textDocument/publishDiagnostics"] = function(_, _, result, _)
        if not bufnr then
            lsp.err_message(
                "LSP.publishDiagnostics: Couldn't find buffer for ", uri)
            return
        end

        lsp.diagnostic.clear(bufnr)
        lsp.diagnostic.save(result.diagnostics, bufnr)
        if vim.api.nvim_buf_get_var(bufnr, "vimrc_lsp_virtual_text_enabled") == 1 then
            lsp.diagnostic.set_virtual_text(result.diagnostics, bufnr)
        end

        if vim.api.nvim_buf_get_var(bufnr, "vimrc_lsp_location_list_enabled") == 1 then
            publish_to_location_list(bufnr, result)
        end

        if vim.api.nvim_buf_get_var(bufnr, "vimrc_lsp_signs_enabled") == 1 then
            lsp.diagnostic.set_signs(result.diagnostics, bufnr)
        end
    end
end


function set_up_keymap(bufnr)
    local opts = { noremap=true, silent=true }
    local is_configured = vim.api.nvim_buf_get_var(bufnr, "is_vimrc_lsp_shortcuts_set")
    local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

    vim.api.nvim_buf_set_option(bufnr, "keywordprg", ":LspHover")
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    if is_configured then
        return
    end

    vim.api.nvim_buf_set_keymap(
        bufnr, "n", "gr", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, "n", "gs", "<Cmd>lua vim.lsp.buf.signature_help()<CR>", opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, "n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, "n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, "n", "g*", "<cmd>lua vim.lsp.buf.references()<CR>", opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, "n", "ge", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, "n", "g0", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, "n", "gw", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, "n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)

    vim.api.nvim_command(
        "command -buffer -nargs=1 LspHover lua vim.lsp.buf.hover()<CR>")

    vim.api.nvim_buf_set_var(bufnr, "is_vimrc_lsp_shortcuts_set", true)
end

function setup_buffer_events(bufnr)
    local is_configured = vim.api.nvim_buf_get_var(bufnr, "is_vimrc_lsp_events_set")
    if is_configured then
        return
    end

    vim.api.nvim_command("augroup vimrc_lsp_" .. bufnr .. "_events")
    vim.api.nvim_command("au!")
    vim.api.nvim_command("autocmd BufLeave,WinLeave,BufDelete,BufWipeout <buffer> lua require'lsp'.stop_buffer_clients(" .. bufnr .. ")")
    vim.api.nvim_command("augroup END")

    vim.api.nvim_buf_set_var(bufnr, "is_vimrc_lsp_events_set", true)
end

function setup_buffer_vars(bufnr)
    if vim.fn.exists("b:is_vimrc_lsp_shortcuts_set") == 0 then
        vim.api.nvim_buf_set_var(bufnr, "is_vimrc_lsp_shortcuts_set", false)
    end

    if vim.fn.exists("b:is_vimrc_lsp_events_set") == 0 then
        vim.api.nvim_buf_set_var(bufnr, "is_vimrc_lsp_events_set", false)
    end

    if vim.fn.exists("b:vimrc_lsp_location_list_enabled") == 0 then
        vim.api.nvim_buf_set_var(bufnr, "vimrc_lsp_location_list_enabled", true)
    end

    if vim.fn.exists("b:vimrc_lsp_signs_enabled") == 0 then
        vim.api.nvim_buf_set_var(bufnr, "vimrc_lsp_signs_enabled", true)
    end

    if vim.fn.exists("b:vimrc_lsp_virtual_text_enabled") == 0 then
        vim.api.nvim_buf_set_var(bufnr, "vimrc_lsp_virtual_text_enabled", true)
    end
end

M.print_buffer_clients = function(bufnr)
    print(vim.inspect(lsp.buf_get_clients(bufnr)))
end

M.is_lsp_running = function(bufnr)
    return next(lsp.buf_get_clients(bufnr)) ~= nil
end

M.stop_buffer_clients = function(bufnr)
    lsp.stop_client(lsp.buf_get_clients(bufnr))
end

M.setup_lsp = function()
    local setup = function(client)
        local bufnr = vim.api.nvim_get_current_buf()
        setup_buffer_vars(bufnr)
        set_up_keymap(bufnr)
        setup_buffer_events(bufnr)

        publish_diagnostics(bufnr)
    end

    local nvim_lsp = require'lspconfig'

    nvim_lsp.pyright.setup{
        on_attach=setup,
        filetypes={"python"},
    }
    nvim_lsp.clangd.setup{
        on_attach=setup,
        filetypes={"cpp", "c"},
    }
    nvim_lsp.rls.setup{
        on_attach=setup,
        filetypes={"rust"},
    }
    nvim_lsp.jsonls.setup{
        on_attach=setup,
        filetypes={"json"},
    }
    nvim_lsp.vimls.setup{
        on_attach=setup,
        filetypes={"vim"},
    }
    nvim_lsp.jdtls.setup{
        on_attach=setup,
        filetypes={"java"},
}
end

return M
