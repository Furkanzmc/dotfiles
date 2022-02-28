local vim = vim
local fn = vim.fn
local helpers = require("null-ls.helpers")
local methods = require("null-ls.methods")
local M = {}

local HOVER = methods.internal.HOVER
local DIAGNOSTICS = methods.internal.DIAGNOSTICS
local FORMATTING = methods.internal.FORMATTING

local function define_pylint_code(cword)
    local lines = {}
    local cache_path = fn.expand("~/.dotfiles/vim/temp_dirs/tmp_files/pylint_messages.txt")
    if fn.filereadable(cache_path) == 0 then
        lines = vim.fn.systemlist("pylint --list-msgs")
        local fh = io.open(cache_path, "w")
        fh:write(table.concat(lines, "\n"))
        fh:close()
    end

    local found = false
    local end_search = false
    for line in io.lines(cache_path) do
        if not found and string.match(line, cword) ~= nil then
            found = true
        elseif found and string.match(line, "^:") ~= nil then
            end_search = true
        elseif found and end_search then
            break
        end

        if found and not end_search then
            table.insert(lines, line)
        end
    end

    return lines
end

M.diagnostics = {
    jq = helpers.make_builtin({
        method = DIAGNOSTICS,
        filetypes = { "json" },
        generator_opts = {
            command = "jq",
            to_stdin = true,
            format = "raw",
            from_stderr = true,
            on_output = helpers.diagnostics.from_errorformat(
                [[parse error: %m %l, column %c]],
                "jq"
            ),
        },
        factory = helpers.generator_factory,
    }),
    cmake_lint = helpers.make_builtin({
        method = DIAGNOSTICS,
        filetypes = { "cmake" },
        generator_opts = {
            command = "cmake-lint",
            args = { "--line-width=100", "$FILENAME" },
            to_stdin = false,
            format = "raw",
            from_stderr = true,
            to_temp_file = true,
            on_output = helpers.diagnostics.from_errorformat(
                table.concat({ "%f:%l: [%t%n] %m", "%f:%l,%c: [%t%n] %m" }, ","),
                "qmllint"
            ),
        },
        factory = helpers.generator_factory,
    }),
}

M.formatting = {
    jq = helpers.make_builtin({
        method = FORMATTING,
        filetypes = { "json" },
        generator_opts = { command = "jq", args = { "--tab" }, to_stdin = true },
        factory = helpers.formatter_factory,
    }),
}

M.hover = {
    pylint_error = helpers.make_builtin({
        name = "pylint_error",
        method = HOVER,
        filetypes = { "python" },
        generator = {
            fn = function(_, done)
                local cword = vim.fn.expand("<cword>")
                done(define_pylint_code(cword))
            end,
            async = true,
            use_cache = true,
        },
    }),
    zettel_context = helpers.make_builtin({
        name = "zettelkasten",
        method = HOVER,
        filetypes = { "markdown" },
        generator = {
            runtime_condition = function(_)
                local zettelkasten_loaded, _ = require("zettelkasten")
                return zettelkasten_loaded
            end,
            fn = function(_, done)
                local cword = vim.fn.expand("<cword>")
                done(
                    require("zettelkasten").keyword_expr(
                        cword,
                        { preview_note = true, return_lines = true }
                    )
                )
            end,
            async = true,
            use_cache = true,
        },
    }),
}

return M
