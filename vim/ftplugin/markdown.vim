setlocal spell
setlocal colorcolumn=80,100
setlocal signcolumn=no

command! -buffer -range RunQML :call qml#run()
