if get(b:, "did_dirvish", v:false)
    finish
endif

setlocal synmaxcol=256

if executable("qlmanage")
    nmap <buffer> <silent> L :call jobstart(["qlmanage", "-p", getline(".")])<CR>
endif

let b:did_dirvish = v:true
