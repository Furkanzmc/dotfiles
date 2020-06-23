local vim = vim
local M = {}
local sign_ns = 'vim_lsp_signs'
local severity_highlights = {
    [vim.lsp.protocol.DiagnosticSeverity.Error] = "LspDiagnosticsError";
    [vim.lsp.protocol.DiagnosticSeverity.Warning] = "LspDiagnosticsWarning";
    [vim.lsp.protocol.DiagnosticSeverity.Information] = "LspDiagnosticsInformation";
    [vim.lsp.protocol.DiagnosticSeverity.Hint] = "LspDiagnosticsHint";
}
local virtual_text_prefixes = {
    [vim.lsp.protocol.DiagnosticSeverity.Error] = vim.api.nvim_get_var('lsp_virtual_text_prefix_error');
    [vim.lsp.protocol.DiagnosticSeverity.Warning] = vim.api.nvim_get_var('lsp_virtual_text_prefix_warning');
    [vim.lsp.protocol.DiagnosticSeverity.Information] = vim.api.nvim_get_var('lsp_virtual_text_prefix_information');
    [vim.lsp.protocol.DiagnosticSeverity.Hint] = vim.api.nvim_get_var('lsp_virtual_text_prefix_hint');
}
local sign_severity_map = {
    [vim.lsp.protocol.DiagnosticSeverity.Error] = "LspDiagnosticsErrorSign";
    [vim.lsp.protocol.DiagnosticSeverity.Warning] = "LspDiagnosticsWarningSign";
    [vim.lsp.protocol.DiagnosticSeverity.Information] = "LspDiagnosticsInformationSign";
    [vim.lsp.protocol.DiagnosticSeverity.Hint] = "LspDiagnosticsHintSign";
}
local diagnostic_ns = vim.api.nvim_create_namespace("vim_lsp_diagnostics")

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

function buf_diagnostics_signs(bufnr, diagnostics)
    for _, diagnostic in ipairs(diagnostics) do
        vim.fn.sign_place(
            0,
            sign_ns,
            sign_severity_map[diagnostic.severity],
            bufnr,
            {lnum=(diagnostic.range.start.line+1)})
    end
end

function buf_diagnostics_virtual_text(bufnr, diagnostics)
    if not diagnostics then
        return
    end

    local include_error = vim.api.nvim_get_var('lsp_virtual_text_include_error_message') == 1
    local buffer_line_diagnostics = vim.lsp.util.diagnostics_group_by_line(diagnostics)

    for line, line_diags in pairs(buffer_line_diagnostics) do
        local virt_texts = {}
        for i = 1, #line_diags - 1 do
            table.insert(virt_texts, {prefix, severity_highlights[line_diags[i].severity]})
        end

        local last = line_diags[#line_diags]
        local prefix = virtual_text_prefixes[last.severity]
        local text = prefix
        if include_error then
            text = text .. " " .. last.message:gsub("\r", ""):gsub("\n", "  ")
        end

        -- TODO(ashkan) use first line instead of subbing 2 spaces?
        table.insert(
            virt_texts, {text, severity_highlights[last.severity]}
            )
        vim.api.nvim_buf_set_virtual_text(bufnr, diagnostic_ns, line, virt_texts, {})
    end
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
            buf_diagnostics_virtual_text(bufnr, result.diagnostics)
        end

        if vim.api.nvim_get_var('lsp_location_list_enabled') == 1 then
            publish_to_location_list(bufnr, result)
        end

        if vim.api.nvim_get_var('lsp_signs_enabled') == 1 then
            buf_diagnostics_signs(bufnr, result.diagnostics)
        end
    end
end


M.print_buffer_clients = function()
    print(vim.inspect(vim.lsp.buf_get_clients()))
end

M.is_lsp_running = function()
    return next(vim.lsp.buf_get_clients()) ~= nil
end

M.stop_buffer_clients = function()
    vim.lsp.stop_client(vim.lsp.get_active_clients())
end

local completion_timer = nil
M.on_complete_done_pre = function()
    if vim.fn.pumvisible() == 1 then
        return
    end

    local info = vim.fn.complete_info()
    if #info.items == 0 then
        if completion_timer == nil then
            completion_timer = vim.loop.new_timer()
            completion_timer:start(5, 0, vim.schedule_wrap(function()
                if vim.fn.pumvisible() == 0 then
                    local mode_keys = "<c-x><c-n>"
                    mode_keys = vim.api.nvim_replace_termcodes(mode_keys, true, false, true)
                    vim.api.nvim_feedkeys(mode_keys, 'n', true)
                end

                completion_timer:stop()
                completion_timer:close()
                completion_timer = nil
            end))
        end
    end
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
    vim.api.nvim_buf_set_keymap(
        bufnr, 'i', '<c-g><c-s>',
        '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

    vim.api.nvim_command(
        "autocmd CompleteDonePre <buffer> lua require'lsp'.on_complete_done_pre()")
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
    elseif file_type == "json" then
        require'nvim_lsp'.jsonls.setup{on_attach=setup}
    elseif file_type == "vim" then
        require'nvim_lsp'.vimls.setup{on_attach=setup}
    end
end

return M
