local vim = vim
local fn = vim.fn
local helpers = require("null-ls.helpers")
local methods = require("null-ls.methods")
local M = {}

local HOVER = methods.internal.HOVER
local DIAGNOSTICS = methods.internal.DIAGNOSTICS
local FORMATTING = methods.internal.FORMATTING
local COMPLETION = methods.internal.COMPLETION

local function from_errorformat(efm, source)
	return function(params, done)
		local output = params.output
		if not output then
			return done()
		end

		local diagnostics = {}
		local lines = vim.split(output, "\n")

		local qflist = vim.fn.getqflist({ efm = efm, lines = lines })
		local severities = { e = 1, w = 2, i = 3, n = 4 }

		for _, item in pairs(qflist.items) do
			if item.valid == 1 then
				local col = item.col > 0 and item.col - 1 or 0
				table.insert(diagnostics, {
					row = item.lnum,
					col = col,
					source = source,
					message = item.text,
					severity = severities[item.type],
				})
			end
		end

		return done(diagnostics)
	end
end

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
			on_output = from_errorformat([[parse error: %m %l, column %c]], "jq"),
		},
		factory = helpers.generator_factory,
	}),
	qmllint = helpers.make_builtin({
		method = DIAGNOSTICS,
		filetypes = { "qml" },
		generator_opts = {
			command = "qmllint",
			args = { "--no-unqualified-id", "$FILENAME" },
			to_stdin = false,
			format = "raw",
			from_stderr = true,
			to_temp_file = true,
			on_output = from_errorformat(table.concat({ "%trror: %m", "%f:%l : %m" }, ","), "qmllint"),
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
			on_output = from_errorformat(table.concat({ "%f:%l: [%t%n] %m", "%f:%l,%c: [%t%n] %m" }, ","), "qmllint"),
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
	qmlformat = helpers.make_builtin({
		method = FORMATTING,
		filetypes = { "qml" },
		generator_opts = {
			command = "qmlformat",
			args = { "-i", "$FILENAME" },
			to_stdin = false,
			to_temp_file = true,
		},
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
}

M.completion = {
	buffers = helpers.make_builtin({
		method = COMPLETION,
		filetypes = {},
		name = "buffers",
		generator_opts = {
			command = "fd",
			args = { "." },
			to_stdin = true,
			format = "raw",
			from_stderr = true,
			on_output = function(params, done)
				return { "asd" }
			end,
		},
		factory = helpers.generator_factory,
	}),
}

return M
