local M = {}

function M.setup()
    require("vimrc.dap").init(nil)

    vim.cmd([[packadd flutter-tools.nvim]])
    require("flutter-tools").setup({
        debugger = {
            enabled = true,
            run_via_dap = true,
        },
        widget_guides = {
            enabled = false,
        },
        closing_tags = {
            highlight = "Comment",
        },
        lsp = {
            on_attach = nil,
            capabilities = function(config)
                config.documentFormattingProvider = false
                return config
            end,
            settings = {
                enableSnippets = false,
                updateImportsOnRename = true,
            },
        },
    })
end

return M
