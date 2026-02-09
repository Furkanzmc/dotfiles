if vim.b.did_ftp == true then
    return
end

-- Settings
vim.opt_local.foldmethod = "indent"
vim.opt_local.signcolumn = "yes"
vim.opt_local.suffixesadd = ".cpp,.h,.hh,.hxx,.cxx,.hpp,_p.h,_p_p.h,.c,.cc"
vim.opt_local.includeexpr = "includeexpr#find(v:fname, [])"
vim.opt_local.commentstring = "//%s"
vim.opt_local.cursorcolumn = false

-- Errorformat
local errorformat = {
    [[Assertion fail%td: (%m)\, function %s\, file %f\, line %l\.]],
    [[error:\ %f:%l:%c:\ %trror:\ %m]],
    [[%E%f:%l:%c:\ %trror:\ %m,%Z%m]],
    [[%W%f:%l:%c:\ %tarning:\ %m,%Z%m]],
    [[%N%f:%l:%c:\ %tote:\ %m,%Z%m]],
    [[%f:%l:%c:\ %trror:\ %m]],
    [[%f:%l:%c:\ %tarning:\ %m]],
    [[%f:%l:%c:\ %tote:\ %m]],
    [[%E%f:%l:\ %trror:\ %m,%Z%m]],
    [[%W%f:%l:\ %tarning:\ %m,%Z%m]],
    [[%N%f:%l:\ %tote:\ %m,%Z%m]],
    [[%f:%l:\ %trror:\ %m]],
    [[%f:%l:\ %tarning:\ %m]],
    [[%f:%l:\ %tote:\ %m]],
    [[%f(%l):\ %trror\ %s%n:\ %m]],
    [[%f(%l):\ %tarning:\ %m]],
    [[%f(%l):\ %tote:\ %m]],
    [[%E%s:\ %f:%l]],
    [[%CTEST\ %tRROR\ %o:\ assertion\ failed\:]],
    [[%Z%m]],
    [[%o:\ passed\ line\ %l:\ %m]],
}

vim.opt_local.errorformat = table.concat(errorformat, ",")

if vim.fn.executable("clang-format") == 1 then
    vim.opt_local.formatprg = "clang-format"
end

if vim.fn.executable("cppman") == 1 then
    vim.opt_local.keywordprg = "cppman"
end

if vim.opt_local.omnifunc:get() == "ccomplete#Complete" then
    vim.opt_local.omnifunc = ""
end

local folder = vim.fn.expand("%:h")
vim.opt_local.path = "./," .. folder
local src, _ = string.find(folder, "src")
if src ~= nil and src > 0 then
    local value, _ = string.gsub(folder, "(.*)src(.*)", "%1include%2")
    vim.opt_local.path:append(value)
end

-- Buffer Variables
vim.b.vimrc_clangd_lsp_signs_enabled = true
vim.b.vimrc_clangd_lsp_virtual_text_enabled = false
vim.b.vimrc_null_ls_lsp_signs_enabled = true
vim.b.vimrc_null_ls_lsp_virtual_text_enabled = false

-- Mappings
vim.keymap.set("n", "<leader>ch", function()
    require("vimrc.cpp").swap_source_header(vim.api.nvim_get_current_buf())
end, { silent = true, buffer = true })

-- Abbreviations helper
local function iabbr(lhs, rhs)
    vim.cmd(string.format("iabbrev <silent> <buffer> %s %s", lhs, rhs))
end

iabbr("#i@", [[#include <><Left><C-R>=abbreviations#eat_char('\s')<CR>]])
iabbr('#i"@', [[#include ""<Left><C-R>=abbreviations#eat_char('\s')<CR>]])
iabbr(
    "once@",
    [[#ifndef MY_HEADER_H<CR>#define MY_HEADER_H<CR><CR><CR>#endif<Up><Up><CR><Up><Up><Up><Esc>fMciw<C-R>=abbreviations#eat_char('\s')<CR>]]
)
iabbr("cout@", [[std::cout << "\n";<Left><Left><Left><Left><C-R>=abbreviations#eat_char('\s')<CR>]])
iabbr("clog@", [[std::clog << "\n";<Left><Left><Left><Left><C-R>=abbreviations#eat_char('\s')<CR>]])
iabbr("cerr@", [[std::cerr << "\n";<Left><Left><Left><Left><C-R>=abbreviations#eat_char('\s')<CR>]])
iabbr(
    "QP@",
    [[Q_PROPERTY(TYPE PH READ PH WRITE setPH NOTIFY PHChanged)<Esc>F(/\(TYPE\\|PH\)<CR><C-R>=abbreviations#eat_char('\s')<CR>]]
)
iabbr(
    "sg@",
    [[<BS><Esc>Hyt<Esc>"tyt f e"nyiwA() const;<Enter>void set<Esc>"npHf llll~A(<Esc>"tpava<BS><BS> value<Esc>A;<C-R>=abbreviations#eat_char('\s')<CR>]]
)
iabbr("g@", [[<BS><Esc>"nyiwA() const;<C-R>=abbreviations#eat_char('\s')<CR>]])
iabbr(
    "s@",
    [[<BS><Esc>"nyiwhml^"tc`lvoid<Right>set<Esc>l~A(<Esc>"tpa<Space>value);<C-R>=abbreviations#eat_char('\s')<CR>]]
)
iabbr("ig@", [[<BS><Esc>F:lyt(A<BS><Enter>{<Enter>return m_<Esc>pa;<Esc>]])
iabbr(
    "is@",
    [[<BS><Esc>F:ftl"nyt(f)b"pyiwA<BS><Enter>{<Enter>if (m_<Esc>"npF_l~"nyiwea==<Esc>"ppo{<Enter>return;<Esc>jo<Esc>"npa=<Esc>"ppa;<Enter>emit <Esc>"npaChanged();<Esc>Bdf_L]]
)
