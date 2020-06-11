local vim = vim
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

function publish_diagnostics()
    local callback = 'textDocument/publishDiagnostics'
    vim.lsp.callbacks[callback] = function(_, _, result, _)
        local bufnr = vim.uri_to_bufnr(result.uri)
        if not bufnr then
            vim.lsp.err_message(
                "LSP.publishDiagnostics: Couldn't find buffer for ", uri)
            return
        end

        vim.lsp.util.buf_clear_diagnostics(bufnr)
        vim.lsp.util.buf_diagnostics_save_positions(bufnr, result.diagnostics)
        if vim.api.nvim_get_var('lsp_virtual_text_enabled') == 1 then
            vim.lsp.util.buf_diagnostics_virtual_text(bufnr, result.diagnostics)
        end

        if vim.api.nvim_get_var('lsp_location_list_enabled') == 1 then
            publish_to_location_list(bufnr, result)
        end
    end
end


M.print_buffer_clients = function()
    print(vim.inspect(vim.lsp.buf_get_clients()))
end

M.stop_buffer_clients = function()
    vim.lsp.stop_client(vim.lsp.get_active_clients())
end


function set_up_keymap(bufnr)
    local opts = { noremap=true, silent=true }

    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', '<leader>f', '<Cmd>lua vim.lsp.buf.formatting()<CR>', opts)
    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', '<leader>lr', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'gs', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'ge', '<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>', opts)
    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'g0', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)

    vim.api.nvim_buf_set_keymap(
        bufnr, 'n', 'gW', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts)
end


M.setup_lsp = function(file_type)
    local setup = function(_, bufnr)
        publish_diagnostics()
        set_up_keymap(bufnr)
    end

    if file_type == "python" then
        require'nvim_lsp'.pyls.setup{on_attach=setup}
    elseif file_type == "cpp" then
        require'nvim_lsp'.clangd.setup{on_attach=setup}
    elseif file_type == "rust" then
        require'nvim_lsp'.rls.setup{on_attach=setup}
    end
end

return M
