local vim = vim
local lsp = vim.lsp
local M = {}

-- Taken from vim/lsp/doagnostic.lua from v0.5.0-832-g35325ddac
M.loclist_type_map = {
    [vim.lsp.protocol.DiagnosticSeverity.Error] = 'E',
    [vim.lsp.protocol.DiagnosticSeverity.Warning] = 'W',
    [vim.lsp.protocol.DiagnosticSeverity.Information] = 'I',
    [vim.lsp.protocol.DiagnosticSeverity.Hint] = 'I'
}

-- Taken from vim/lsp/doagnostic.lua from v0.5.0-832-g35325ddac
function M.to_severity(severity)
    if not severity then return nil end
    return type(severity) == 'string' and DiagnosticSeverity[severity] or
               severity
end

function M.find_open_window(buffer)
    local current_tab = vim.fn.tabpagenr()
    local last_tab = vim.fn.tabpagenr('$')
    for tabnr = 1, last_tab, 1 do
        local buffers = vim.fn.tabpagebuflist(tabnr)
        for winnr, bufnr in ipairs(buffers) do
            if buffer == bufnr then
                return {tabnr = tabnr, winnr = winnr}
            end
        end
    end

    return {tabnr = -1, winnr = -1}
end

function M.set_loclist(bufnr, identifier, items, title)
    local winnr = M.find_open_window(bufnr).winnr
    local existing_items = vim.fn.getloclist(winnr)
    for _, item in ipairs(existing_items) do
        if string.match(item.text, identifier) == nil then
            table.insert(items, item)
        end
    end

    table.sort(items, function(a, b) return a.lnum < b.lnum end)
    vim.fn.setloclist(winnr, {}, 'r', {title = title, items = items})
end

function table.index_of(tab, val)
    for index, value in ipairs(tab) do if value == val then return index end end

    return -1
end

function table.extend(source, target)
    for _, v in ipairs(target) do table.insert(source, v) end

    return source
end

function table.filter(t, pred)
    local out = {}

    for k, v in pairs(t) do if pred(v, k, t) then table.insert(out, v) end end

    return out
end

function M.range(a, b, step)
    if not b then
        b = a
        a = 1
    end
    step = step or 1
    local f = step > 0 and function(_, lastvalue)
        local nextvalue = lastvalue + step
        if nextvalue <= b then return nextvalue end
    end or step < 0 and function(_, lastvalue)
        local nextvalue = lastvalue + step
        if nextvalue >= b then return nextvalue end
    end or function(_, lastvalue) return lastvalue end
    return f, nil, a - step
end

function table.uniq(t)
    local new_table = {}
    local hash = {}
    for _, v in pairs(t) do
        if not hash[v] then
            table.insert(new_table, v)
            hash[v] = true
        end
    end

    return new_table
end

function string.join(str, ch)
    local joined = ""
    for _, word in ipairs(str) do joined = joined .. ch .. word end

    return joined
end

function string.split(str, sep)
    local ret = {}
    local n = 1
    for w in str:gmatch("([^" .. sep .. "]*)") do
        ret[n] = ret[n] or w -- only set once (so the blank after a string is ignored)
        if w == "" then n = n + 1 end -- step forwards on a blank but not a string
    end
    return ret
end

return M

-- vim: foldmethod=marker
