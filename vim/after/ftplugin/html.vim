setlocal colorcolumn=120
setlocal suffixesadd=.html

execute "SetIndentSize 2"

if get(s:, "html_plugin_loaded", v:false)
    finish
endif

let s:html_plugin_loaded = v:true
