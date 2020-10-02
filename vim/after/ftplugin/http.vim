if !get(s:, "vimrc_http_plugins_loaded", v:false)
    packadd nvim-http
    let s:vimrc_http_plugins_loaded = v:true
endif

