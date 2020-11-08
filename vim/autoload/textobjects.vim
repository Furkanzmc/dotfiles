function! textobjects#url_text_object()
  let l:url_regex = '\(https\|http\)\?:\/\/\(\w\+\(:\w\+\)\?@\)\?\([A-Za-z][-_0-9A-Za-z]*\.\)\{1,}\(\w\{2,}\.\?\)\{1,}\(:[0-9]\{1,5}\)\?\S*'
  if search(l:url_regex, 'ceW')
    normal v
    call search(l:url_regex, 'bcW')
  endif
endfunction

