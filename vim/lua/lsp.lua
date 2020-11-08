local vim = vim
local lsp = vim.lsp.util
local M = {}


function publish_to_location_list(bufnr, local_result)
    if local_result and local_result.diagnostics then
        for _, v in ipairs(local_result.diagnostics) do
            v.uri = v.uri or local_result.uri
        end
    end

    local locations = vim.lsp.util.locations_to_items(local_result.diagnostics)
    vim.fn.setloclist(
        bufnr,
        locations,
        "r")
end

function publish_diagnostics(bufnr)
    local callback = 'textDocument/publishDiagnostics'
    vim.lsp.callbacks[callback] = function(_, _, result, _)
        if not bufnr then
            vim.lsp.err_message(
                "LSP.publishDiagnostics: Couldn't find buffer for ", uri)
            return
        end

        vim.lsp.util.buf_clear_diagnostics(bufnr)
        vim.lsp.util.buf_diagnostics_save_positions(bufnr, result.diagnostics)
        if vim.api.nvim_buf_get_var(bufnr, 'vimrc_lsp_virtual_text_enabled') == 1 then
            lsp.buf_diagnostics_virtual_text(bufnr, result.diagnostics)
        end

        if vim.api.nvim_buf_get_var(bufnr, 'vimrc_lsp_location_list_enabled') == 1 then
            publish_to_location_list(bufnr, result)
        end

        if vim.api.nvim_buf_get_var(bufnr, 'vimrc_lsp_signs_enabled') == 1 then
            lsp.buf_diagnostics_signs(bufnr, result.diagnostics)
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
        bufnr, 'n', 'gr', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'gs', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'g*', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'ge', '<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>', opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'g0', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'gw', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)

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
    print(vim.inspect(vim.lsp.buf_get_clients(bufnr)))
end

M.is_lsp_running = function(bufnr)
    return next(vim.lsp.buf_get_clients(bufnr)) ~= nil
end

M.stop_buffer_clients = function(bufnr)
    vim.lsp.stop_client(vim.lsp.buf_get_clients(bufnr))
end

M.setup_lsp = function(file_type)
    local setup = function(client)
        local bufnr = vim.api.nvim_get_current_buf()
        setup_buffer_vars(bufnr)
        set_up_keymap(bufnr)
        setup_buffer_events(bufnr)

        publish_diagnostics(bufnr)
    end

    if file_type == "python" then
        require'nvim_lsp'.pyls.setup{on_attach=setup}
    elseif file_type == "cpp" then
        require'nvim_lsp'.clangd.setup{on_attach=setup}
    elseif file_type == "rust" then
        require'nvim_lsp'.rls.setup{on_attach=setup}
    elseif file_type == "json" then
        require'nvim_lsp'.jsonls.setup{on_attach=setup}
    elseif file_type == "vim" then
        require'nvim_lsp'.vimls.setup{on_attach=setup}
    elseif file_type == "java" then
        require'nvim_lsp'.jdtls.setup{on_attach=setup}
    end
end

return M
