function! windows#create_floating_window(rw, rh)
    let width = min([&columns - 4, max([80, float2nr(&columns * a:rw)])])
    let height = min([&lines - 4, max([20, float2nr(&lines * a:rh)])])
    let top = ((&lines - height) / 2) - 1
    let left = (&columns - width) / 2

    let opts = {
                \ "relative": "editor",
                \ "row": top,
                \ "col": left,
                \ "width": width,
                \ "height": height,
                \ "style": "minimal"
                \ }

    let top = "‾" . repeat("‾", width - 2) . "‾"
    let mid = "|" . repeat(" ", width - 2) . "|"
    let bot = "_" . repeat("_", width - 2) . "_"
    let frame_lines = [top] + repeat([mid], height - 2) + [bot]

    let s:frame_buffer = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(s:frame_buffer, 0, -1, v:true, frame_lines)
    let s:frame_window = nvim_open_win(s:frame_buffer, v:true, opts)

    " Adjust size so that the frame is visible.
    let opts.row += 1
    let opts.height -= 2
    let opts.col += 2
    let opts.width -= 4

    let s:buffer = nvim_create_buf(v:false, v:true)
    let s:window = nvim_open_win(s:buffer, v:true, opts)
    au BufWinLeave <buffer> exe "bw ". s:frame_buffer

    return s:buffer
endfunction
