setlocal commentstring=//\ %s
setlocal colorcolumn=120

execute "SetIndentSize 2"

if get(s:, "vue_plugin_loaded", v:false)
    finish
endif

let s:vue_plugin_loaded = v:true
