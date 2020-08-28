command -complete=customlist,custom_sort#sort_command_completion -range -nargs=1
            \ Sort :call custom_sort#sort(<f-args>, <line1>, <line2>)

