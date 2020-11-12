function! quickfix#toggle()
    let tpbl = []
    call extend(tpbl, tabpagebuflist(tabpagenr()))

    let l:is_open = v:false
    for idx in tpbl
        if getbufvar(idx, "&buftype", "ERROR") == "quickfix"
            let l:is_open = v:true
            break
        endif
    endfor

    if l:is_open
        cclose
    else
        copen
    endif
endfunction

function! quickfix#show_item_in_preview(use_loclist, linenr)
    if a:use_loclist
        let l:list = getloclist(winnr())
        let l:list_name = "loclist"
    else
        let l:list = getqflist()
        let l:list_name = "qflist"
    endif

    let l:type_mapping = {
                \ "E": "Error",
                \ "W": "Warning",
                \ "I": "Info",
                \ }

    let l:lines = []
    for item in l:list
        if get(item, "lnum", -1) == a:linenr
            let l:type = get(item, "type", "I")
            let l:type = get(l:type_mapping, l:type, "")
            let l:text = get(item, "text", "")
            call add(l:lines, l:type . ": " . l:text)
        endif
    endfor

    if len(l:lines) > 0
        call preview#show("QuickFix Item", l:lines)
    else
        echohl WarningMsg
        echo "[quickfix] No item in " . l:list_name
        echohl Normal
    endif
endfunction
