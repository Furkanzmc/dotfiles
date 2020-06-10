local vim = vim
local M = {}

function block_callback()
    local callback = 'textDocument/publishDiagnostics'
    vim.lsp.callbacks[callback] = function(_, _, result, _)
        -- Do nothing.
    end
end


M.on_attach = function(_, _)
    block_callback()
end

return M
