if get(b:, "did_ftp", v:false)
    finish
endif

if !get(s:, "vimrc_cpp_plugins_loaded", v:false) && &loadplugins
    packadd tagbar
    let s:vimrc_cpp_plugins_loaded = v:true
endif

setlocal foldmethod=indent
setlocal signcolumn=yes
setlocal suffixesadd=.cpp,.h,.hxx,.cxx,.hpp,_p.h,_p_p.h,.c
setlocal includeexpr=cpp#includeexpr(v:fname)
setlocal commentstring=//%s
setlocal nocursorline
setlocal nocursorcolumn

" Assertion
let &l:errorformat = 'Assertion fail%td: (%m)\, function %s\, file %f\, line %l\.'

" Clang errorformat
setlocal errorformat+=error:\ %f:%l:%c:\ %trror:\ %m

setlocal errorformat+=%E%f:%l:%c:\ %trror:\ %m,%Z%m
setlocal errorformat+=%W%f:%l:%c:\ %tarning:\ %m,%Z%m
setlocal errorformat+=%N%f:%l:%c:\ %tote:\ %m,%Z%m

setlocal errorformat+=%f:%l:%c:\ %trror:\ %m
setlocal errorformat+=%f:%l:%c:\ %tarning:\ %m
setlocal errorformat+=%f:%l:%c:\ %tote:\ %m

setlocal errorformat+=%E%f:%l:\ %trror:\ %m,%Z%m
setlocal errorformat+=%W%f:%l:\ %tarning:\ %m,%Z%m
setlocal errorformat+=%N%f:%l:\ %tote:\ %m,%Z%m

setlocal errorformat+=%f:%l:\ %trror:\ %m
setlocal errorformat+=%f:%l:\ %tarning:\ %m
setlocal errorformat+=%f:%l:\ %tote:\ %m

" MSVC errorformat
setlocal errorformat+=%f(%l):\ %trror\ %s%n:\ %m
setlocal errorformat+=%f(%l):\ %tarning:\ %m
setlocal errorformat+=%f(%l):\ %tote:\ %m

" Test Error
setlocal errorformat+=%E%s:\ %f:%l,%CTEST\ %tRROR\ %o:\ assertion\ failed\:,\ %Z%m
setlocal errorformat+=%o:\ passed\ line\ %l:\ %m

if executable("clang-format")
    setlocal formatprg=clang-format
endif

if executable("cppman")
    setlocal keywordprg=cppman
endif

if &l:omnifunc == "ccomplete#Complete"
    setlocal omnifunc=
endif

let b:vimrc_clangd_lsp_signs_enabled = v:true
let b:vimrc_clangd_lsp_virtual_text_enabled = v:false
let b:vimrc_null_ls_lsp_signs_enabled = v:true
let b:vimrc_null_ls_lsp_virtual_text_enabled = v:false

nnoremap <silent> <buffer> <leader>ch :lua require"vimrc.cpp".swap_source_header()<CR>

" Abbreviations {{{

abbreviate <silent> <buffer> #i@ #include <><Left><C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> #i"@ #include ""<Left><C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> once@ #ifndef MY_HEADER_H<CR>#define MY_HEADER_H<CR><CR><CR>#endif<Up><Up><CR><Up><Up><Up><Esc>fMciw<C-R>=abbreviations#eat_char('\s')<CR>

abbreviate <silent> <buffer> cout@ std::cout << "\n";<Left><Left><Left><Left><C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> clog@ std::clog << "\n";<Left><Left><Left><Left><C-R>=abbreviations#eat_char('\s')<CR>
abbreviate <silent> <buffer> cerr@ std::cerr << "\n";<Left><Left><Left><Left><C-R>=abbreviations#eat_char('\s')<CR>

" Q_PROPERTY abbreviation.
abbreviate <silent> <buffer> QP@ Q_PROPERTY(TYPE PH READ PH WRITE setPH NOTIFY PHChanged)<Esc>F(/\(TYPE\\|PH\)<CR><C-R>=abbreviations#eat_char('\s')<CR>

" Abbreviation to create a getter and setter.
" Example: int count sg@<Space>
abbreviate <silent> <buffer> sg@ <BS><Esc>Hyt<Esc>"tyt f e"nyiwA() const;<Enter>void set<Esc>"npHf llll~A(<Esc>"tpava<BS><BS> value<Esc>A;<C-R>=abbreviations#eat_char('\s')<CR>

" Abbreviation to getter.
" Example: int count g@<Space>
abbreviate <silent> <buffer> g@ <BS><Esc>"nyiwA() const;<C-R>=abbreviations#eat_char('\s')<CR>

" Create a setter.
" Example: int count s@<Space>
abbreviate <silent> <buffer> s@ <BS><Esc>"nyiwhml^"tc`lvoid<Right>set<Esc>l~A(<Esc>"tpa<Space>value);<C-R>=abbreviations#eat_char('\s')<CR>

" Abbreviation to getter implementation.
" Example: int MyClass::count(); ig@<Space>
abbreviate <silent> <buffer> ig@ <BS><Esc>F:lyt(A<BS><Enter>{<Enter>return m_<Esc>pa;<Esc>

" Abbreviation to setter implementation.
" Example: int MyClass::setCount(int value); ig@<Space>
abbreviate <silent> <buffer> is@ <BS><Esc>F:ftl"nyt(f)b"pyiwA<BS><Enter>{<Enter>if (m_<Esc>"npF_l~"nyiwea==<Esc>"ppo{<Enter>return;<Esc>jo<Esc>"npa=<Esc>"ppa;<Enter>emit <Esc>"npaChanged();<Esc>Bdf_L

" }}}

function cpp#includeexpr(fname)
    return includeexpr#find(a:fname, [])
endfunction
