local vim = vim
local M = {}

function block_callback()
    local callback = 'textDocument/publishDiagnostics'
    vim.lsp.callbacks[callback] = function(_, _, result, _)
        -- Do nothing.
    end
end


M.on_attach = function(block_diagnostics)
    if block_diagnostics then
        block_callback()
    end
end

M.print_buffer_clients = function()
    print(vim.inspect(vim.lsp.buf_get_clients()))
end

M.stop_buffer_clients = function()
    vim.lsp.stop_client(vim.lsp.get_active_clients())
end


M.setup_lsp = function(file_type)
    local setup_blocking = function()
        require'lsp'.on_attach(true)
    end

    local setup = function()
        require'lsp'.on_attach(false)
    end

    if file_type == "python" then
        require'nvim_lsp'.pyls.setup{on_attach=setup_blocking}
    elseif file_type == "cpp" then
        require'nvim_lsp'.clangd.setup{on_attach=setup}
    elseif file_type == "rust" then
        require'nvim_lsp'.rls.setup{on_attach=setup}
    end
end

return M
