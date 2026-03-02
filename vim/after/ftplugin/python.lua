if vim.b.did_ftp == true then
    return
end

if vim.g.vimrc_python_loaded_plugins == nil and vim.o.loadplugins then
    vim.g.vimrc_python_loaded_plugins = true
end

vim.bo.cindent = true
vim.bo.expandtab = true
vim.bo.autoindent = true

vim.wo.foldmethod = "indent"
vim.wo.signcolumn = "yes"
vim.opt_local.wildignore:append({ "*.pyc", "__pycache__" })

vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4

vim.opt_local.smarttab = false
vim.wo.linebreak = true
vim.bo.textwidth = 110

vim.bo.indentexpr = ""
vim.bo.suffixesadd = ".py"

vim.opt_local.cursorcolumn = false

if vim.fn.executable("black") == 1 then
    vim.bo.formatprg = "black --quiet -"
end

vim.b.vimrc_null_ls_lsp_signs_enabled = 1
vim.b.vimrc_pyright_lsp_signs_enabled = 1

-- Abbreviations
vim.cmd([[abbreviate <silent> <buffer> im@ import <C-R>=abbreviations#eat_char('\s')<CR>]])
vim.cmd([[abbreviate <silent> <buffer> imdt@ from datetime import datetime<C-R>=abbreviations#eat_char('\s')<CR>]])
vim.cmd([[abbreviate <silent> <buffer> imtz@ from django.utils import timezone<C-R>=abbreviations#eat_char('\s')<CR>]])
vim.cmd([[abbreviate <silent> <buffer> im_@ from django.utils.translation import ugettext_lazy as _<C-R>=abbreviations#eat_char('\s')<CR>]])
vim.cmd([[abbreviate <silent> <buffer> pr@ print("[lame_debugging::<C-r>=expand("%:t")<CR>::<C-r>=line('.')<CR>]")<Esc>F"a,<Space><C-R>=abbreviations#eat_char('\s')<CR>]])
vim.cmd([[abbreviate <silent> <buffer> true True]])
vim.cmd([[abbreviate <silent> <buffer> false False]])

-- includeexpr
_G.python_includeexpr = function(fname)
    local search_paths = { ".venv/lib/*/site-packages" }
    return vim.fn["includeexpr#find"](fname:gsub("%.", "/"), search_paths)
end

vim.bo.includeexpr = "v:lua.python_includeexpr(v:fname)"
