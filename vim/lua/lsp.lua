local vim = vim
local lsp = vim.lsp
local M = {}

-- Implementation is from runtime/lua/vim/lsp/util.lua
-- The original implementation uses the line as text, instead of the message.
function locations_to_items(client, bufnr, locations)
    local function sort_by_key(fn)
        return function(a,b)
            local ka, kb = fn(a), fn(b)
            assert(#ka == #kb)
            for i = 1, #ka do
                if ka[i] ~= kb[i] then
                    return ka[i] < kb[i]
                end
            end
            -- every value must have been equal here, which means it's not less than.
            return false
        end
    end
    local position_sort = sort_by_key(function(v)
        return {v.start.line, v.start.character}
    end)
    local items = {}
    local grouped = setmetatable({}, {
            __index = function(t, k)
                local v = {}
                rawset(t, k, v)
                return v
            end;
        })
    for _, d in ipairs(locations) do
        -- locations may be Location or LocationLink
        local uri = d.uri or d.targetUri
        local range = d.range or d.targetSelectionRange
        table.insert(grouped[uri], {start = range.start, message=d.message})
    end

    local keys = vim.tbl_keys(grouped)
    table.sort(keys)
    -- TODO(ashkan) I wish we could do this lazily.
    for _, uri in ipairs(keys) do
        local rows = grouped[uri]
        table.sort(rows, position_sort)
        local bufnr = vim.uri_to_bufnr(uri)
        vim.fn.bufload(bufnr)
        local filename = vim.uri_to_fname(uri)
        for _, temp in ipairs(rows) do
            local pos = temp.start
            local row = pos.line
            local col = lsp.util.character_offset(bufnr, row, pos.character)
            table.insert(items, {
                    filename = filename,
                    lnum = row + 1,
                    col = col + 1,
                    text = "[" .. client.name .. "] " .. temp.message;
                })
        end
    end

    return items
end


function publish_to_location_list(client, bufnr, local_result)
    if local_result and local_result.diagnostics then
        for _, v in ipairs(local_result.diagnostics) do
            v.uri = v.uri or local_result.uri
        end
    end

    -- TODO: Clear only the items that we add here so we can share the location
    -- list with others.
    local items = locations_to_items(client, bufnr, local_result.diagnostics)

    vim.fn.setloclist(
        bufnr,
        items,
        "r")
end

function publish_diagnostics(client)
    local api = vim.api
    client.handlers["textDocument/publishDiagnostics"] = function(_, _, result, client_id)
        local client = lsp.get_client_by_id(client_id)
        local bufnr = vim.uri_to_bufnr(result.uri)
        if not bufnr then
            lsp.err_message(
                "LSP.publishDiagnostics: Couldn't find buffer for ", uri)
            return
        end

        lsp.diagnostic.clear(bufnr, client_id)
        lsp.diagnostic.save(result.diagnostics, bufnr, client_id)
        if vim.api.nvim_buf_get_var(bufnr, "vimrc_" .. client.name .. "_lsp_virtual_text_enabled") == 1 then
            lsp.diagnostic.set_virtual_text(result.diagnostics, bufnr)
        end

        if vim.api.nvim_buf_get_var(bufnr, "vimrc_" .. client.name .. "_lsp_location_list_enabled") == 1 then
            publish_to_location_list(client, bufnr, result)
        end

        if vim.api.nvim_buf_get_var(bufnr, "vimrc_" .. client.name .. "_lsp_signs_enabled") == 1 then
            lsp.diagnostic.set_signs(result.diagnostics, bufnr, client_id)
        end
    end
end


function set_up_keymap(client, bufnr)
    local opts = { noremap=true, silent=true }
    local is_configured = vim.api.nvim_buf_get_var(bufnr, "is_vimrc_" .. client.name .. "_lsp_shortcuts_set")
    local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
    local resolved_capabilities = client.resolved_capabilities

    vim.api.nvim_buf_set_option(bufnr, "keywordprg", ":LspHover")
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    if is_configured then
        return
    end

    if resolved_capabilities.rename == true then
        vim.api.nvim_buf_set_keymap(
            bufnr, "n", "gr", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)
    end

    if resolved_capabilities.signature_help == true then
        vim.api.nvim_buf_set_keymap(
            bufnr, "n", "gs", "<Cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    end

    if resolved_capabilities.goto_definition == true then
        vim.api.nvim_buf_set_keymap(
            bufnr, "n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
    end

    if resolved_capabilities.declaration == true then
        vim.api.nvim_buf_set_keymap(
            bufnr, "n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    end

    if resolved_capabilities.implementation == true then
        vim.api.nvim_buf_set_keymap(
            bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    end

    if resolved_capabilities.find_references == true then
        vim.api.nvim_buf_set_keymap(
            bufnr, "n", "g*", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    end

    vim.api.nvim_buf_set_keymap(
        bufnr, "n", "ge", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)

    if resolved_capabilities.document_symbol == true then
        vim.api.nvim_buf_set_keymap(
            bufnr, "n", "g0", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts)
    end

    if resolved_capabilities.workspace_symbol == true then
        vim.api.nvim_buf_set_keymap(
            bufnr, "n", "gw", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", opts)
    end

    if resolved_capabilities.code_action == true then
        vim.api.nvim_buf_set_keymap(
            bufnr, "n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    end

    if resolved_capabilities.document_formatting == true then
        vim.api.nvim_buf_set_keymap(
            bufnr, "n", "gq", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    end

    if resolved_capabilities.hover == true then
        vim.api.nvim_command(
            "command -buffer -nargs=1 LspHover lua vim.lsp.buf.hover()<CR>")
    end

    vim.api.nvim_buf_set_var(bufnr, "is_vimrc_" .. client.name .. "_lsp_shortcuts_set", true)
end

function setup_auto_stop(client, bufnr)
    local is_configured = vim.api.nvim_buf_get_var(bufnr, "is_vimrc_" .. client.name .. "_lsp_events_set")
    if is_configured then
        return
    end

    vim.api.nvim_command("augroup vimrc_" .. client.name .. "_lsp_" .. bufnr .. "_events")
    vim.api.nvim_command("au!")
    vim.api.nvim_command("autocmd BufLeave,WinLeave,BufDelete,BufWipeout <buffer> lua require'lsp'.stop_buffer_clients(" .. client.id .. ")")
    vim.api.nvim_command("augroup END")

    vim.api.nvim_buf_set_var(bufnr, "is_vimrc_" .. client.name .. "_lsp_events_set", true)
end

function setup_buffer_vars(client, bufnr)
    if vim.fn.exists("b:is_vimrc_" .. client.name .. "_lsp_shortcuts_set") == 0 then
        vim.api.nvim_buf_set_var(bufnr, "is_vimrc_" .. client.name .. "_lsp_shortcuts_set", false)
    end

    if vim.fn.exists("b:is_vimrc_" .. client.name .. "_lsp_events_set") == 0 then
        vim.api.nvim_buf_set_var(bufnr, "is_vimrc_" .. client.name .. "_lsp_events_set", false)
    end

    if vim.fn.exists("b:vimrc_" .. client.name .. "_lsp_location_list_enabled") == 0 then
        vim.api.nvim_buf_set_var(bufnr, "vimrc_" .. client.name .. "_lsp_location_list_enabled", true)
    end

    if vim.fn.exists("b:vimrc_" .. client.name .. "_lsp_signs_enabled") == 0 then
        vim.api.nvim_buf_set_var(bufnr, "vimrc_" .. client.name .. "_lsp_signs_enabled", true)
    end

    if vim.fn.exists("b:vimrc_" .. client.name .. "_lsp_virtual_text_enabled") == 0 then
        vim.api.nvim_buf_set_var(bufnr, "vimrc_" .. client.name .. "_lsp_virtual_text_enabled", true)
    end
end

M.print_buffer_clients = function(bufnr)
    print(vim.inspect(lsp.buf_get_clients(bufnr)))
end

M.is_lsp_running = function(bufnr)
    return next(lsp.buf_get_clients(bufnr)) ~= nil
end

M.stop_buffer_clients = function(client_id, bufnr)
    lsp.stop_client(client_id)
end

M.setup_lsp = function()
    local setup = function(client)
        local bufnr = vim.api.nvim_get_current_buf()

        setup_buffer_vars(client, bufnr)
        setup_auto_stop(client, bufnr)
        set_up_keymap(client, bufnr)
        publish_diagnostics(client)
    end

    local setup_without_formatting = function(client)
        client.resolved_capabilities.document_formatting = false
        setup(client)
    end

    local lspconfig = require'lspconfig'

    lspconfig.pyright.setup{
        on_attach=setup_without_formatting,
        filetypes={"python"},
    }
    lspconfig.clangd.setup{
        on_attach=setup_without_formatting,
        filetypes={"cpp", "c"},
    }
    lspconfig.rls.setup{
        on_attach=setup_without_formatting,
        filetypes={"rust"},
    }
    lspconfig.jsonls.setup{
        on_attach=setup_without_formatting,
        filetypes={"json"},
    }
    lspconfig.vimls.setup{
        on_attach=setup_without_formatting,
        filetypes={"vim"},
    }
    lspconfig.jdtls.setup{
        on_attach=setup_without_formatting,
        filetypes={"java"},
    }

    lspconfig.efm.setup{
        on_attach=setup,
        filetypes={"qml", "python", "cpp", "json", "c"}
    }
end

return M
