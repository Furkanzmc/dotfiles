local vim = vim
local lsp = vim.lsp
local futils = require("futils")
local M = {}

-- Taken from vim/lsp/doagnostic.lua from v0.5.0-832-g35325ddac
M.loclist_type_map = {
	[vim.lsp.protocol.DiagnosticSeverity.Error] = "E",
	[vim.lsp.protocol.DiagnosticSeverity.Warning] = "W",
	[vim.lsp.protocol.DiagnosticSeverity.Information] = "I",
	[vim.lsp.protocol.DiagnosticSeverity.Hint] = "I",
}

-- Taken from vim/lsp/doagnostic.lua from v0.5.0-832-g35325ddac
function M.to_severity(severity)
	if not severity then
		return nil
	end
	return type(severity) == "string" and DiagnosticSeverity[severity] or severity
end

function M.find_open_window(buffer)
	local current_tab = vim.fn.tabpagenr()
	local last_tab = vim.fn.tabpagenr("$")
	for tabnr = 1, last_tab, 1 do
		local buffers = vim.fn.tabpagebuflist(tabnr)
		for winnr, bufnr in ipairs(buffers) do
			if buffer == bufnr then
				return { tabnr = tabnr, winnr = winnr }
			end
		end
	end

	return { tabnr = -1, winnr = -1 }
end

function M.set_loclist(bufnr, identifier, items, title)
	local winnr = M.find_open_window(bufnr).winnr
	local existing_items = vim.fn.getloclist(winnr)
	for _, item in ipairs(existing_items) do
		if string.match(item.text, identifier) == nil then
			table.insert(items, item)
		end
	end

	table.sort(items, function(a, b)
		return a.lnum < b.lnum
	end)
	vim.fn.setloclist(winnr, {}, "r", { title = title, items = items })
end

function M.range(a, b, step)
	if not b then
		b = a
		a = 1
	end
	step = step or 1
	local f = step > 0
			and function(_, lastvalue)
				local nextvalue = lastvalue + step
				if nextvalue <= b then
					return nextvalue
				end
			end
		or step < 0 and function(_, lastvalue)
			local nextvalue = lastvalue + step
			if nextvalue >= b then
				return nextvalue
			end
		end
		or function(_, lastvalue)
			return lastvalue
		end
	return f, nil, a - step
end

return M

-- vim: foldmethod=marker
