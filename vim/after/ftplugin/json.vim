setlocal foldmethod=indent
setlocal cursorline

if executable("jq")
    setlocal formatprg=jq
endif

let b:vimrc_jsonls_lsp_signs_enabled = 1
let b:vimrc_jsonls_lsp_virtual_text_enabled = 1
let b:vimrc_jsonls_lsp_location_list_enabled = 1
