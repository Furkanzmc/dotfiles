func abbreviations#eat_char(pattern)
  let l:letter = nr2char(getchar(0))
  return (l:letter =~ a:pattern) ? '' : l:letter
endfunc
