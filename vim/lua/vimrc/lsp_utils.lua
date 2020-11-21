local vim = vim
local api = vim.api
local lsp = vim.lsp
local utils = require"vimrc.utils"
local M = {}

-- Utils {{{

-- Taken from vim/lsp/doagnostic.lua from v0.5.0-832-g35325ddac
--- Sets the location list
---@param opts table|nil Configuration table. Keys:
---         - {open_loclist}: (boolean, default true)
---             - Open loclist after set
---         - {client_id}: (number)
---             - If nil, will consider all clients attached to buffer.
---         - {severity}: (DiagnosticSeverity)
---             - Exclusive severity to consider. Overrides {severity_limit}
---         - {severity_limit}: (DiagnosticSeverity)
---             - Limit severity of diagnostics found. E.g. "Warning" means { "Error", "Warning" } will be valid.
function M.set_loclist(opts)
    opts = opts or {}
    assert(opts.client_id ~= nil)
    assert(opts.bufnr ~= nil)

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

        local line = (api.nvim_buf_get_lines(bufnr, row, row + 1, false) or {""})[1]

        table.insert(items, {
                bufnr = bufnr,
                lnum = row + 1,
                col = col + 1,
                context = 320,
                text = "[" .. client.name .. "]" .. " | " .. line .. " | " .. diag.message,
                type = utils.loclist_type_map[diag.severity or DiagnosticSeverity.Error] or 'E',
            })
    end

    for _, diag in ipairs(buffer_diags) do
        insert_diag(diag)
    end

    utils.set_loclist(opts.bufnr, client.name, items, "LSP")
    if open_loclist then
        vim.cmd [[lopen]]
    end
end

-- }}}

return M
