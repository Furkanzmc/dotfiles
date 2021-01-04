if get(b:, "vimrc_dirvish_did_dirvish", v:false)
    finish
endif

if get(g:, "vimrc_dirvish_virtual_text_enabled", v:false)
    let b:vimrc_dirvish_did_dirvish = v:true
    finish
endif

if !exists("g:vimrc_dirvish_virtual_text_prefix")
    let g:vimrc_dirvish_virtual_text_prefix = "> "
endif

if executable("qlmanage")
    nmap <buffer> <silent> L :call jobstart(["qlmanage", "-p", getline(".")])<CR>
endif

if has("mac")
    nmap <buffer> <silent> R :call jobstart(["open", "--reveal", getline(".")])<CR>
endif

nmap <buffer> <silent> S :lua require"vimrc.plugins.dirvish".show_status(1, vim.fn.line("$"))<CR>
vmap <buffer> <silent> S :lua require"vimrc.plugins.dirvish".show_status(vim.fn.line("'<"), vim.fn.line("'>"))<CR>
nmap <buffer> <silent> C :lua require"vimrc.plugins.dirvish".toggle_conceal()<CR>

lua require"vimrc.plugins.dirvish".init()

let b:vimrc_dirvish_did_dirvish = v:true
